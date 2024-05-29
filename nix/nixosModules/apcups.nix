# Module for machines connected to an APC UPS

{ config, lib, ... }:

with lib;

let
  cfg = config.lunik1.system.apcups;
in
{
  options.lunik1.system.apcups.enable = mkEnableOption "APC UPS integration";

  config = lib.mkIf cfg.enable { services.apcupsd.enable = true; };
}
