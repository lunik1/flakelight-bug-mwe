# Setup for ssh access

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.ssh-server;
in
{
  options.lunik1.system.ssh-server.enable = lib.mkEnableOption "ssh access";

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 1002 ];
      startWhenNeeded = lib.mkDefault false;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
      };
    };

    users.users.corin.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkSRk4VCfwnoNBH/dT5F3mRbYV9U9yt6NNb6XpbVTan openpgp:0x2559C602"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpM/AZjpBrMzy7o5gMKPJMa0stjzc9wyn6Y2RC6FzsJ"
    ];

    # Also allow access with et
    services.eternal-terminal.enable = true;
  };
}
