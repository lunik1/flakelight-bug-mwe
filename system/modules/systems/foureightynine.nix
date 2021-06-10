{ config, lib, pkgs, modulesPath, ... }:

let cfg = config.lunik1.system.systems.foureightynine;
in {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  options.lunik1.system.systems.foureightynine.enable =
    lib.mkEnableOption "foureightynine-specific config";

  config = lib.mkIf cfg.enable {
    networking.hostName = "foureightynine";

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
        kernelModules = [ "dm-snapshot" "i915" ];
        luks.devices = {
          root = {
            device = "/dev/disk/by-uuid/6a10e5fa-0a63-49cf-9c88-f3fa3ff78a83";
            preLVM = true;
            allowDiscards = true;
          };
        };
      };

      kernelModules = [ "kvm-intel" ];
      kernelParams = [ "intel_pstate=active" ];
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

    swapDevices =
      [{ device = "/dev/disk/by-uuid/23df6352-3bba-47ce-96fb-2c98ba1580e7"; }];

    # No scheduler for non-rotational disks
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    '';

    nix.maxJobs = lib.mkDefault 4;
    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

    hardware = {
      cpu.intel.updateMicrocode = true;
      enableAllFirmware = true;

      # Intel graphics
      opengl = {
        enable = true;
        driSupport32Bit = true; # for steam
        extraPackages = with pkgs; [
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          intel-media-driver
        ];
      };
    };

    system.stateVersion = "19.09";
  };
}
