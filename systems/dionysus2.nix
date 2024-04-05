{ moduleArgs }:

{
  system = "x86_64-linux";
  modules = [
    ({ config, pkgs, modulesPath, ... }:
      {
        require = [ (modulesPath + "/installer/scan/not-detected.nix") ]
          ++ import ../modules/system/module-list.nix;

        ### System-specific config incl. hardware scan
        networking.hostName = "dionysus2";
        system.stateVersion = "18.03";
        nix.settings.max-jobs = 8;
        powerManagement.cpuFreqGovernor = "powersave";

        hardware = {
          cpu.intel.updateMicrocode = true;
          enableAllFirmware = true;
        };

        environment.systemPackages = with pkgs; [ samba ];

        boot = {
          initrd.availableKernelModules =
            [ "xhci_pci" "ahci" "usb_storage" "uas" "sd_mod" ];

          loader.grub.device = "/dev/disk/by-id/ata-TS240GMTS420S_G377480650";

          tmp.useTmpfs = false;

          kernelModules = [ "kvm-intel" "bfq" ];
          kernelPackages = pkgs.linuxPackages;
          kernelParams = [ "mce=0" ]; # Panic on uncorrectable ECC ram error
          kernel.sysctl = {
            "kernel.yama.ptrace_scope" = 1; # will break strace, gdb etc.
          };
          blacklistedKernelModules = [ "f2fs" "ufs" ];
          extraModulePackages = [ ];
        };

        console = {
          packages = [ pkgs.terminus_font ];
          font = "ter-132n";
        };

        ## We shouldn't need to replace the kernel image, so don't allow it
        security = {
          protectKernelImage = true;
          # lockKernelModules = true;  # breaks docker
        };

        environment.variables = {
          "KOPIA_CHECK_FOR_UPDATES" = "false";
          "KOPIA_BYTES_STRING_BASE_2" = "true";
        };

        networking = {
          # Set DHCP on specific interface, as recommened in docstring
          useDHCP = false;
          interfaces.eno2.useDHCP = true;

          enableIPv6 = false; # no support on my ISP :(
        };

        ## Filesystems
        # disable fsck for xfs systems, as fsck.xfs is a noop
        fileSystems = {
          "/" = {
            device = "/dev/disk/by-id/ata-TS240GMTS420S_G377480650-part1";
            fsType = "xfs";
          };
          "/mnt/parity1" = {
            device = "/dev/disk/by-id/ata-HGST_HDN728080ALE604_R6G8UBUY-part1";
            fsType = "xfs";
            noCheck = true;
          };
          "/mnt/parity2" = {
            device = "/dev/disk/by-id/ata-ST8000DM004-2CX188_WCT1JHV8-part1";
            fsType = "xfs";
            noCheck = true;
          };
          "/mnt/data1" = {
            device = "/dev/disk/by-id/ata-ST8000VN0022-2EL112_ZA19D4YD-part1";
            fsType = "xfs";
            noCheck = true;
          };
          "/mnt/data2" = {
            device = "/dev/disk/by-id/ata-TOSHIBA_HDWN180_Z7A2K3RVFP9E-part1";
            fsType = "xfs";
            noCheck = true;
          };
          "/mnt/data3" = {
            device =
              "/dev/disk/by-id/ata-TOSHIBA_MG06ACA800E_91J0A09VFKRE-part1";
            fsType = "xfs";
            noCheck = true;
          };
          "/mnt/storage" = {
            device =
              "${pkgs.mergerfs}/bin/mergerfs#/mnt/data1:/mnt/data2:/mnt/data3";
            fsType = "fuse";
            noCheck = true;
            options = [
              "defaults"
              "nonempty"
              "allow_other"
              "use_ino"
              "fsname=mergerfs"
              "minfreespace=10G"
              "func.getattr=newest"
              "cache.files=auto-full"
              "category.create=mfs"
              # "cache.writeback=true"
              "cache.symlinks=true"
              "ignorepponrename=true"
              "cache.readdir=true"
              "cache.open=1"
              "dropcacheonclose=true"
              "symlinkify=true"
            ];
          };
        };

        # programs.fuse.userAllowOther = true;

        swapDevices =
          [{ device = "/dev/disk/by-id/ata-TS240GMTS420S_G377480650-part2"; }];

        # and make /storage accessible over samba
        services = {
          nfs = {
            server = {
              enable = true;
              exports = ''
                /mnt/storage 192.168.0.0/16(rw,insecure,fsid=0)
              '';
            };
          };
          samba = {
            enable = true;
            extraConfig = ''
              workgroup = WORKGROUP
              server string = dionysus
              security = user
              guest ok = yes
              map to guest = Bad Password
              wins support = yes
              local master = yes
              preferred master = yes
            '';
            shares = {
              storage = {
                path = "/mnt/storage";
                browseable = "yes";
                "read only" = "no";
                "guest ok" = "no";
                "force user" = "corin";
                "force group" = "users";
              };
            };
          };
        };

        # UPS
        services.apcupsd.enable = true;

        ## Use bfq for rotational drives
        services.udev.extraRules = ''
          ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
        '';

        ## Monitor network usage
        services.vnstat.enable = true;

        ## Back up permissions info on /storage
        systemd.services.storage-permissions-backup = {
          description = "Backup permissions on /mnt/storage";
          startAt = "14:07";
          serviceConfig = {
            Type = "oneshot";
            ExecStart =
              "/bin/sh -c '{ ${pkgs.acl}/bin/getfacl -p -R /mnt/storage | ${pkgs.zstd}/bin/zstd -T0 -10 > /root/storage_permissions.acl.zst.tmp ; } && ${pkgs.busybox}/bin/mv /root/storage_permissions.acl.zst.tmp /root/storage_permissions.acl.zst'";
            Nice = "15";
            IOSchedulingClass = "best-effort";
            IOSchedulingPriority = "6";
          };
        };

        ## Update DNS records reguarly
        services.inadyn = {
          enable = true;
          interval = "*:0/15";
          configFile = config.sops.secrets."inadyn.conf".path;
        };

        ## Sync kopia to remote
        sops.secrets = {
          kopia_connection_config_remote = {
            sopsFile = ../secrets/host/dionysus2/secrets.yaml;
          };
          kopia_connection_config = { };
          kopia_environment = { };
        };

        systemd.services.kopia-sync = {
          description = "Sync to remote kopia repository";
          startAt = "Tue 06:41";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.kopia}/bin/kopia repository sync-to from-config --config-file ${config.sops.secrets.kopia_connection_config.path} --file ${config.sops.secrets.kopia_connection_config_remote.path} --delete --parallel 8 --times";
            EnvironmentFile = config.sops.secrets.kopia_environment.path;

            TimeoutStartSec = "6d";

            Nice = 18;
            IOSchedulingPriority = 6;
            CPUSchedulingPolicy = "batch";

            User = "root";

            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = "@system-service";
            SystemCallErrorNumber = "EPERM";
            CapabilityBoundingSet = "CAP_DAC_OVERRIDE";
          };
        };

        services.snapraid = {
          enable = true;
          scrub.plan = 15;
          parityFiles =
            [ "/mnt/parity1/snapraid.parity" "/mnt/parity2/snapraid.parity" ];
          contentFiles = [
            "/var/snapraid.content"
            "/mnt/data1/.snapraid.content"
            "/mnt/data2/.snapraid.content"
            "/mnt/data3/.snapraid.content"
          ];
          dataDisks = {
            d1 = "/mnt/data1/";
            d2 = "/mnt/data2/";
            d3 = "/mnt/data3/";
          };
          exclude = [
            "*.!sync"
            "*.unrecoverable"
            ".AppleDB"
            ".AppleDouble"
            ".DS_Store"
            ".Spotlight-V100"
            ".TemporaryItems"
            ".Thumbs.db"
            ".Trashes"
            "._.DS_Store"
            "._AppleDouble"
            ".fseventsd"
            "/.boinc/"
            "/.downloads/"
            "/excluded/"
            "/lost+found/"
            "/tmp/"
          ];
        };

        sops.secrets = {
          "inadyn.conf" = {
            sopsFile = ../secrets/host/dionysus2/secrets.yaml;
          };
        };

        users.users.corin.linger = true;

        ## Config modules to use
        lunik1.system = {
          backup.enable = true;
          containers.enable = true;
          grub.enable = true;
          munin.enable = true;
          locate.enable = true;
          network.resolved.enable = true;
          ssh-server.enable = true;
          zswap.enable = true;
        };
      })
  ];
}
