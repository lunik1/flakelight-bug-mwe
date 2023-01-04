# System networking configuration

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.network;
in {
  options.lunik1.system.network = with lib.types; {
    resolved.enable = lib.mkEnableOption "resolved";
    networkmanager.enable = lib.mkEnableOption "network manager";
    dnsOverTls = lib.mkOption {
      default = true;
      type = bool;
      description = "Whether to use DNS-over-TLS (DoT)";
    };
    nameservers = lib.mkOption {
      default = if cfg.resolved.enable && cfg.dnsOverTls then [
        # recommended by https://www.privacyguides.org/dns/
        "194.242.2.2#doh.mullvad.net"
        "45.90.30.0#anycast.dns.nextdns.io"
        "76.76.2.11#p0.freedns.controld.com"
        "9.9.9.9#dns.quad9.net"
      ] else [
        "194.242.2.2"
        "45.90.30.0"
        "76.76.2.11"
        "9.9.9.9"
      ];
      type = listOf str;
    };
  };

  config = {
    assertions = with cfg; [{
      assertion = dnsOverTls -> resolved.enable;
      message = "DNS-over-TLS support requires resolved";
    }];

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
      fallbackDns = [ "" ];
      extraConfig = ''
        DNSOverTLS=${lib.boolToString cfg.dnsOverTls};
      '';
    };
  };
}
