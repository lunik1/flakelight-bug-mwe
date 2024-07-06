{
  system = "x86_64-linux";
  modules = [
    (
      {
        lib,
        modulesPath,
        pkgs,
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

        nix.settings.max-jobs = 4;
        powerManagement.cpuFreqGovernor = "ondemand";

        hardware = {
          cpu.intel.updateMicrocode = true;
          enableAllFirmware = true;

          # Intel graphics
          graphics = {
            enable = true;
            extraPackages = with pkgs; [
              vaapiIntel
              vaapiVdpau
              libvdpau-va-gl
              intel-media-driver
            ];
          };
        };
        environment.variables.LIBVA_DRIVER_NAME = "iHD";

        ## Config modules to use
        lunik1.system = {
          backup.enable = true;
          bluetooth.enable = true;
          graphical.enable = true;
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

        # Provide sway
        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
          extraPackages = [ ];
        };
      }
    )
  ];
}
