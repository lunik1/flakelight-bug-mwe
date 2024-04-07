# System printing and scanning configuration

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.pulp-io;
in {
  options.lunik1.system.pulp-io.enable =
    lib.mkEnableOption "printing and scanning support";

  config = lib.mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      extraBackends = with pkgs; [ sane-airscan ];
    };
    services.printing = {
      enable = true;
      drivers = with pkgs; [ brlaser ];
    };

    users.users.corin.extraGroups = [ "scanner" "lp" ];
  };
}
