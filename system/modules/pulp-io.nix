# System printing and scanning configuration
# For now, just supports HP printers

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.pulp-io;
in {
  options.lunik1.system.pulp-io.enable =
    lib.mkEnableOption "printing and scanning support";

  config = lib.mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.hplip ];
    };
    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    users.users.corin.extraGroups = [ "scanner" "lp" ];
  };
}
