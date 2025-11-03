{
  inputs,
  outputs,
  hmModules,
  ...
}:

{
  system = "x86_64-linux";
  modules = [
    (
      {
        lib,
        modulesPath,
        pkgs,
        config,
        ...
      }:

      {
        require = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        ## System-specific config incl. hardware scan
        networking.hostName = "foureightynine";
        system.stateVersion = "19.09";

        boot = {
          kernelPackages = pkgs.linuxPackages_zen;
          initrd = {
            availableKernelModules = [
              "ahci"
              "xhci_pci"
              "usb_storage"
              "sd_mod"
              "sdhci_pci"
              "rtsx_usb_sdmmc"
            ];
            kernelModules = [
              "dm-snapshot"
              "i915"
            ];
            luks.devices = {
              root = {
                device = "/dev/disk/by-uuid/6a10e5fa-0a63-49cf-9c88-f3fa3ff78a83";
                preLVM = true;
                allowDiscards = true;
              };
            };
          };

          kernelModules = [ "kvm-intel" ];
          blacklistedKernelModules = [ "iCTO_wdt" ]; # watchdog module
          kernelParams = [
            "intel_pstate=active"
            "nowatchdog"
          ];
          extraModulePackages = [ ];
        };

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/58490821-0e88-4573-b673-921c64b63b0f";
          fsType = "ext4";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/BD42-C7A0";
          fsType = "vfat";
        };

        swapDevices = [ { device = "/dev/disk/by-uuid/23df6352-3bba-47ce-96fb-2c98ba1580e7"; } ];

        # No scheduler for non-rotational disks
        services.udev.extraRules = ''
          ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
        '';

        # Updating firmware with fwupd on this machine has given me very weird
        # filesystem errors
        services.fwupd.enable = lib.mkForce false;

        systemd.network.wait-online.enable = false;

        nix = {
          daemonIOSchedClass = "idle";
          daemonCPUSchedPolicy = lib.mkForce "idle";
          settings.max-jobs = 4;
        };
        powerManagement.cpuFreqGovernor = "ondemand";

        hardware = {
          cpu.intel.updateMicrocode = true;
          enableAllFirmware = true;

          # Intel graphics
          graphics = {
            enable = true;
            extraPackages = with pkgs; [
              intel-media-driver
              intel-vaapi-driver
              libva-vdpau-driver
              libvdpau-va-gl
            ];
          };
        };
        environment.variables.LIBVA_DRIVER_NAME = "iHD";

        sops.secrets = {
          kopia-repo-url = { };
          kopia-password = {
            sopsFile = ../../secrets/host/foureightynine/secrets.yaml;
          };
        };

        # Provide sway
        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
          extraPackages = [ ];
        };

        ## Config modules to use
        lunik1.system = {
          bluetooth.enable = true;
          graphical.enable = true;
          kopia-backup = {
            enable = true;
            interval = "10:34";
            urlFile = config.sops.secrets.kopia-repo-url.path;
            passwordFile = config.sops.secrets.kopia-password.path;
          };
          laptop.enable = true;
          network = {
            resolved.enable = true;
            networkmanager.enable = true;
          };
          pulp-io.enable = true;
          sound.enable = true;
          systemd-boot.enable = true;
          zswap.enable = true;
        };

        home-manager.users.corin = {
          imports = hmModules;

          home = {
            username = "corin";
            homeDirectory = "/home/corin";
            stateVersion = "20.09";
          };

          lunik1.home = {
            waybar.batteryModule = true;

            cli.enable = true;
            gui.enable = true;

            bluetooth.enable = config.lunik1.system.bluetooth.enable;
            emacs.enable = true;
            fonts.enable = true;
            games.cli.enable = true;
            git.enable = true;
            gpg.enable = true;
            gtk.enable = true;
            megacmd.enable = true;
            mpv.enable = true;
            music = {
              enable = true;
              mpd.enable = true;
            };
            neovim.enable = true;
            pulp-io.enable = true;
            sway.enable = true;
            syncthing.enable = true;

            lang = {
              c.enable = true;
              data.enable = true;
              julia.enable = true;
              nix.enable = true;
              prose.enable = true;
              python.enable = true;
              rust.enable = true;
              sh.enable = true;
            };
          };
        };
      }
    )
  ];
}
