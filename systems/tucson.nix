{ pkgsForSystem, modules }:

let
  system = "x86_64-linux";
  pkgs = pkgsForSystem system;
in
{
  inherit system;
  modules = [
    ({ config, modulesPath, ... }:

      {
        require = [ (modulesPath + "/installer/scan/not-detected.nix") ]
          ++ import ../modules/system/module-list.nix;

        nixpkgs.pkgs = pkgs;

        environment.systemPackages = with pkgs; [ nfs-utils cifs-utils ];

        ## System-specific config incl. hardware scan
        networking.hostName = "tucson";
        system.stateVersion = "21.05";

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;

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
            kernelModules = [ "dm-snapshot" "i2c-dev" "i2c-piix4" ];
          };

          binfmt.emulatedSystems = [ "aarch64-linux" ];

          tmp.useTmpfs = true;
        };

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/91ba7453-e8af-4bc6-ba40-6444992232f9";
          fsType = "xfs";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/99D0-07B0";
          fsType = "vfat";
        };

        sops.secrets = {
          samba-credentials = {
            sopsFile = ../secrets/host/tucson/secrets.yaml;
          };
        };
        fileSystems."/mnt/storage" = {
          device = "//192.168.0.20/storage";
          fsType = "cifs";
          noCheck = true;
          options = [ "x-systemd.automount" "x-systemd.mount-timeout=30" "noauto" "nofail" "_netdev" "credentials=${config.sops.secrets.samba-credentials.path}" ];
        };

        swapDevices = [{
          device = "/dev/disk/by-uuid/67f65c58-4d31-4ea4-8b70-44d1e98a48e0";
        }];

        # No scheduler for non-rotational disks
        services.udev.extraRules = ''
          ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
        '';

        nix.settings = {
          max-jobs = 4;
          cores = 8;
        };

        hardware = {
          cpu.amd.updateMicrocode = true;
          enableAllFirmware = true;
        };

        services.hardware = {
          openrgb = {
            enable = true;
            motherboard = "amd";
          };
        };

        services.udisks2 = {
          enable = true;
          mountOnMedia = true;
        };

        ## Config modules to use
        lunik1.system = {
          amdgpu = {
            enable = true;
            support32Bit = true;
            opencl = true;
          };
          backup.enable = true;
          bluetooth.enable = true;
          containers.enable = true;
          graphical.enable = true;
          kde.enable = true;
          network = {
            resolved.enable = true;
            networkmanager.enable = true;
          };
          pulp-io.enable = true;
          sddm.enable = true;
          sound.enable = true;
          systemd-boot.enable = true;
          zswap.enable = true;
        };
      })
  ] ++ modules;
}
