# Module for machines connected to an APC UPS

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lunik1.system.apcups;
in {
  options.lunik1.system.enable = mkEnableOption "APC UPS integration";

  config = lib.mkIf cfg.enable {
    services.apcupsd.locate = true;

    users.users.corin.extraGroups = [ "mlocate" ];
  };
}
