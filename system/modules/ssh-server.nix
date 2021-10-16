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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0+cUVaESw5u7V/S7tAmKSYE0u0Ij7eOsxH2rgzGXLH corin@thesus"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID17KStyIU+A23dghTW/6a/sR71Za8prKJcAkZrrhbJm corin@foureightynine"
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
      challengeResponseAuthentication = false;
      macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };

    users.users.corin.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0+cUVaESw5u7V/S7tAmKSYE0u0Ij7eOsxH2rgzGXLH corin@thesus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzMGelXQHdhXbxlTJ+DzW+b8Lojkawr7+9JmftgzeCI corin@dionysus2"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID17KStyIU+A23dghTW/6a/sR71Za8prKJcAkZrrhbJm corin@foureightynine"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1djimfe24mF+GRzwWlYULJtmJ7hbiMvSoel0tR4ZFd corin@hermes"
    ];

    # Also allow access with et
    services.eternal-terminal.enable = true;
  };
}
