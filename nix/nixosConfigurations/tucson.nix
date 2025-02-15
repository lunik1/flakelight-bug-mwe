{
  system = "x86_64-linux";
  modules = [
    (
      {
        config,
        pkgs,
        lib,
        modulesPath,
        ...
      }:
      {
        require = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        environment.systemPackages = with pkgs; [
          nfs-utils
          cifs-utils
        ];

        ## System-specific config incl. hardware scan
        networking = {
          hostName = "tucson";
          enableIPv6 = false;
          nftables.enable = true;
          firewall.enable = lib.mkForce true;
        };
        system.stateVersion = "21.05";

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;

          kernel.sysctl = {
            # https://wiki.archlinux.org/title/Gaming#Tweaking_kernel_parameters_for_response_time_consistency
            "vm.compaction_proactiveness" = 0;
            "vm.watermark_boost_factor" = 1;
            "vm.min_free_kbytes" = 1048576;
            "vm.watermark_scale_factor" = 500;
          };

          blacklistedKernelModules = [ "iCTO_wdt" ]; # watchdog module

          initrd = {
            luks.devices.nixos = {
              preLVM = true;
              allowDiscards = true;
              device = "/dev/disk/by-uuid/cdd84488-5be8-44a3-b886-ae2492d2be29";
            };
            availableKernelModules = [
              "nvme"
              "xhci_pci"
              "ahci"
              "uas"
              "usb_storage"
              "usbhid"
              "sd_mod"
            ];
            kernelModules = [
              "dm-snapshot"
              "i2c-dev"
              "i2c-piix4"
            ];
          };

          binfmt.emulatedSystems = [ "aarch64-linux" ];

          tmp.useTmpfs = true;
        };

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-uuid/91ba7453-e8af-4bc6-ba40-6444992232f9";
            fsType = "xfs";
          };
          "/boot" = {
            device = "/dev/disk/by-uuid/99D0-07B0";
            fsType = "vfat";
          };
        };

        sops.secrets = {
          kopia-repo-url = { };
          kopia-password = {
            sopsFile = ../../secrets/host/tucson/secrets.yaml;
          };
        };

        swapDevices = [ { device = "/dev/disk/by-uuid/67f65c58-4d31-4ea4-8b70-44d1e98a48e0"; } ];

        nix = {
          daemonIOSchedClass = "idle";
          daemonCPUSchedPolicy = lib.mkForce "idle";
          settings = {
            max-jobs = 4;
            cores = 8;
          };
        };

        hardware = {
          amdgpu = {
            initrd.enable = true;
            opencl.enable = true;
          };
          cpu.amd.updateMicrocode = true;
          enableAllFirmware = true;
        };

        services = {
          # No scheduler for non-rotational disks
          udev.extraRules = ''
            ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
          '';
          hardware = {
            openrgb = {
              enable = true;
              package = pkgs.openrgb-with-all-plugins;
              motherboard = "amd";
            };
          };
          udisks2 = {
            enable = true;
            mountOnMedia = true;
          };
        };

        systemd = {
          network.wait-online.enable = false;

          services.openrgb.serviceConfig.ExecStart =
            with config.services.hardware.openrgb;
            lib.mkForce "${package}/bin/openrgb --server --server-port ${toString server.port} --profile ${../../resources/io.orp}";
        };

        powerManagement.resumeCommands = ''
          systemctl restart openrgb.service
        '';

        ## Config modules to use
        lunik1.system = {
          bluetooth.enable = true;
          containers.enable = true;
          games = {
            enable = true;
            steam.enable = true;
          };
          graphical.enable = true;
          gnome.enable = true;
          kopia-backup = {
            enable = true;
            interval = "22:07";
            urlFile = config.sops.secrets.kopia-repo-url.path;
            passwordFile = config.sops.secrets.kopia-password.path;
          };
          network = {
            resolved.enable = true;
            networkmanager.enable = true;
          };
          pulp-io.enable = true;
          sound.enable = true;
          systemd-boot.enable = true;
          zswap.enable = true;
        };
      }
    )
  ];
}
