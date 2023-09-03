{ overlays, modules }:

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

        boot = {
          kernelPackages = pkgs.linuxPackages_hardened;
          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
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

        networking = {
          hostName = "mercury2";
          nftables.enable = true;
          firewall = {
            enable = lib.mkForce true;
            allowedUDPPorts = [
              53 # dns
              21027 # syncthing
            ];
            allowedTCPPorts = [
              53
              80 # http
              443 # https
              5432
              22000 # syncthing
            ];
          };
        };
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
  ] ++ modules;
}
