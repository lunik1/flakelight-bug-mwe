# Setup for containers (podman)

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.system.containers;
in
{
  options.lunik1.system.containers = {
    enable = lib.mkEnableOption "containerisation";
    updateOnRebuild = lib.mkEnableOption "updating containers on nixos-rebuild";
  };

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

    system.activationScripts = lib.optionalAttrs cfg.updateOnRebuild {
      updateContainers = {
        text = ''
          ${lib.getExe pkgs.ploy} update-containers
        '';
      };
    };
  };
}
