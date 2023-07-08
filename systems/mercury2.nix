overlays:

{
  system = "aarch64-linux";
  modules = [
    ({ pkgs, lib, modulesPath, ... }:

      {
        require = [
          (modulesPath + "/installer/scan/not-detected.nix")
          (modulesPath + "/profiles/qemu-guest.nix")
        ]
        ++ import ../modules/system/module-list.nix;

        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        fileSystems = {
          "/" = { device = "/dev/disk/by-label/nixos"; fsType = "xfs"; };
          "/boot" = { device = "/dev/disk/by-label/boot"; fsType = "vfat"; };
          "/var/lib" = { device = "/dev/disk/by-label/state"; fsType = "xfs"; };
        };

        swapDevices = [
          { device = "/dev/disk/by-label/swap"; }
        ];

        nixpkgs = {
          overlays = overlays;
          hostPlatform = lib.mkDefault "aarch64-linux";
        };

        networking.hostName = "mercury2";
        system.stateVersion = "23.05";
        nix.settings = {
          max-jobs = 2;
          cores = 4;
        };

        ## Config modules to use
        lunik1.system = {
          backup.enable = true;
          containers.enable = true;
          network.resolved.enable = true;
          ssh-server.enable = true;
        };
      })
  ];
}
