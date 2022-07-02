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
      extraBackends = with pkgs; [ epson-escpr ];
    };
    services.printing = {
      enable = true;
      drivers = with pkgs; [ epson-escpr ];
    };

    users.users.corin.extraGroups = [ "scanner" "lp" ];
  };
}
