# Setup for ssh access

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.ssh-server;
in {
  options.lunik1.system.ssh-server.enable = lib.mkEnableOption "ssh access";

  config = lib.mkIf cfg.enable {
    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        hostKeys = [ /etc/secrets/initrd/ssh_host_ed25519_key ];
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkSRk4VCfwnoNBH/dT5F3mRbYV9U9yt6NNb6XpbVTan openpgp:0x2559C602"
        ];
        port = 1002;
      };
    };

    services.openssh = {
      enable = true;
      ports = [ 1002 ];
      startWhenNeeded = lib.mkDefault false;
      permitRootLogin = "no";
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };

    users.users.corin.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkSRk4VCfwnoNBH/dT5F3mRbYV9U9yt6NNb6XpbVTan openpgp:0x2559C602"
    ];

    # Also allow access with et
    services.eternal-terminal.enable = true;
  };
}
