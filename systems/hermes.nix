{
  system = "x86_64-linux";
  modules = [
    ({ pkgs, lib, modulesPath, ... }:

      {
        require = [ (modulesPath + "/installer/scan/not-detected.nix") ]
          ++ import ../modules/system/module-list.nix;

        ### System-specific config incl. hardware scan
        networking.hostName = "hermes";
        system.stateVersion = "21.05";
        nix.maxJobs = 8;

        ## Add ability to muotn nfs
        # environment.systemPackages = with pkgs; [ nfsUtils ];

        fileSystems."/mnt/nas" = {
          device = "172.16.129.119:/nas/4657";
          fsType = "nfs";
        };

        # Disable earlyoom
        services.earlyoom.enable = lib.mkForce false;

        ## Config modules to use
        lunik1.system = {
          backup.enable = true;
          containers.enable = true;
          network = {
            resolved.enable = true;
            nameservers =
              [ "37.205.9.100" "37.205.10.88" ]; # vpsFree internal DNS
          };
          ssh-server.enable = true;
          vpsadminos.enable = true;
        };
      })
  ];
}
