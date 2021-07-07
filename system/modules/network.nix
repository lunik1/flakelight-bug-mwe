# System networking configuration

{ config, lib, pkgs, ... }:

let
  cfg = config.lunik1.system.network;
  nameservers = [ "91.239.100.100 " "89.233.43.71 " ]; # Uncensored DNS
in {
  options.lunik1.system.network = {
    resolved.enable = lib.mkEnableOption "resolved";
    connman.enable = lib.mkEnableOption "connman";
  };

  config = {
    networking = {
      firewall.enable = false;
      inherit nameservers;
    };
    services = {
      connman = lib.mkIf cfg.connman.enable {
        enable = true;
        wifi.backend = "iwd";
      };
      resolved = lib.mkIf cfg.resolved.enable {
        enable = true;
        dnssec = "false";
        fallbackDns = nameservers;
      };
    };
  };
}
