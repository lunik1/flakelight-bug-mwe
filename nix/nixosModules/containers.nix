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
    autoPrune = lib.mkEnableOption "periodically prune Podman resources";
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
      autoPrune.enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    systemd.services.update-containers = lib.optionalAttrs cfg.updateOnRebuild {
      description = "Update containers after activation";
      wantedBy = [ "multi-user.target" ];
      after = [
        "nixos-activation.target"
        "podman.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.update-containers}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectProc = "invisible";
        ProtectHome = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
      };
    };
  };
}
