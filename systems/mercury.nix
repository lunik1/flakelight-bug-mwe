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

        fileSystems = {
          "/" = { device = "/dev/mapper/ocivolume-root"; fsType = "xfs"; };
          "/boot" = { device = "/dev/sda1"; fsType = "vfat"; };
        };

        nixpkgs.overlays = overlays;

        networking.hostName = "mercury";
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
          oci.enable = true;
          ssh-server.enable = true;
        };
      })
  ];
}
