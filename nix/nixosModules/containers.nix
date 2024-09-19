# Setup for containers (podman)

{ config, lib, ... }:

let
  cfg = config.lunik1.system.containers;
in
{
  options.lunik1.system.containers.enable = lib.mkEnableOption "containerisation";

  config = lib.mkIf cfg.enable {
    environment = {
      variables = {
        COMPOSE_HTTP_TIMEOUT = "600";
        PGID = "100";
        PUID = "1000";
      };
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
