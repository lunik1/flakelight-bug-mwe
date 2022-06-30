# System networking configuration

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.network;
in {
  options.lunik1.system.network = with lib.types; {
    resolved.enable = lib.mkEnableOption "resolved";
    networkmanager.enable = lib.mkEnableOption "network manager";
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
    networking.networkmanager = lib.mkIf cfg.networkmanager.enable {
      enable = true;
      plugins = [ pkgs.networkmanager-openvpn ];
      wifi.backend = "iwd";
      wifi.powersave = true;
    };
    services.resolved = lib.mkIf cfg.resolved.enable {
      enable = true;
      dnssec = "false";
      fallbackDns = cfg.nameservers;
    };
  };
}
