# Setup for containers (podman)

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.containers;
in {
  options.lunik1.system.containers.enable =
    lib.mkEnableOption "containerisation";

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [ arion docker-client docker_compose ];
      variables = {
        COMPOSE_HTTP_TIMEOUT = "600";
        PGID = "100";
        PUID = "1000";
      };
    };

    virtualisation.podman = {
      enable = true;
      dockerSocket.enable = true;
      defaultNetwork.dnsname.enable = true;
    };
  };
}
