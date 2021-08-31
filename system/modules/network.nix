# System networking configuration

{ config, lib, pkgs, ... }:

let
  cfg = config.lunik1.system.network;
in {
  options.lunik1.system.network = with lib.types; {
    resolved.enable = lib.mkEnableOption "resolved";
    connman.enable = lib.mkEnableOption "connman";
    nameservers = lib.mkOption {
      default = [ "91.239.100.100" "89.233.43.71" ]; # UncensoredDNS
      type = listOf str;
    };
  };

  config = {
    networking = {
      firewall.enable = false;
      nameservers = cfg.nameservers;
    };
    services = {
      connman = lib.mkIf cfg.connman.enable {
        enable = true;
        wifi.backend = "iwd";
      };
      resolved = lib.mkIf cfg.resolved.enable {
        enable = true;
        dnssec = "false";
        fallbackDns = cfg.nameservers;
      };
    };
  };
}
