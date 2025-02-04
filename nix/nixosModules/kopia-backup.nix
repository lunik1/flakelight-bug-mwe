# Module for regular backups with kopia

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.lunik1.system.kopia-backup;
in
{
  options.lunik1.system.kopia-backup = with types; {
    enable = mkEnableOption "regular backups via Kopia";

    interval = mkOption {
      default = "03:46";
      type = str;
    };

    urlFile = mkOption {
      default = "";
      type = str;
    };

    passwordFile = mkOption {
      type = str;
    };
  };

  config =
    let
      user = "kopia";
      group = "kopia";
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.kopia ];

      systemd.services.kopia-create = {
        description = "Backup to kopia repository";
        startAt = cfg.interval;
        serviceConfig = {
          Type = "oneshot";

          LoadCredential = [
            "kopia-repo-url:${cfg.urlFile}"
            "kopia-password:${cfg.passwordFile}"
          ];

          ExecStartPre = [
            "/bin/sh -c 'KOPIA_PASSWORD=$(< %d/kopia-password) ${lib.getExe pkgs.kopia} repository connect server --url $(< %d/kopia-repo-url)'"
          ];
          ExecStart = "/run/wrappers/bin/kopia snapshot create --no-use-keyring /"; # use wrapped kopia to bypass r/w restrictions
          ExecStopPost = "${lib.getExe pkgs.kopia} repository disconnect";

          Environment = [
            "KOPIA_CHECK_FOR_UPDATES=false"
            "KOPIA_BYTES_STRING_BASE_2=true"
          ];

          # can get stuck if connection fails
          TimeoutStartSec = "18h";

          Nice = 19;
          IOSchedulingPriority = 7;
          CPUSchedulingPolicy = "batch";

          User = user;

          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = "@system-service";
          SystemCallErrorNumber = "EPERM";
        };
      };

      users = {
        users.${user} = {
          inherit group;
          createHome = true;
          home = "/var/lib/kopia";
          isSystemUser = true;
        };
        groups.kopia = { };
      };

      security.wrappers = {
        kopia = {
          inherit group;
          source = "${pkgs.kopia}/bin/kopia";
          owner = user;
          permissions = "u=rwx,g=,o=";
          capabilities = "cap_dac_read_search=+ep";
        };
      };
    };
}
