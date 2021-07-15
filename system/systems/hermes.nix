{ config, lib, pkgs, modulesPath, ... }:

let cfg = config.lunik1.system.systems.dionysus2;
in {
  require = [ (modulesPath + "/installer/scan/not-detected.nix") ]
    ++ import ../modules/module-list.nix;

  ### System-specific config incl. hardware scan
  networking.hostName = "hermes";
  system.stateVersion = "21.05";
  nix.maxJobs = 8;

  ## Config modules to use
  lunik1.system = {
    containers.enable = true;
    network.resolved.enable = true;
    ssh-server.enable = true;
    vpsadminos.enable = true;
  };
}
