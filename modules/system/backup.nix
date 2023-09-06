# Module for regular backups
# Will need to connect as root to Kopia backup server before with
# kopia repositoty connect

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lunik1.system.backup;
in {
  options.lunik1.system.backup = with types; {
    enable = mkEnableOption "regular backups via Kopia";
    interval = mkOption {
      default = "03:46";
      type = str;
    };
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.kopia ];

    sops.secrets = {
      kopia_environment = { };
      kopia_connection_config = { };
    };

    systemd.services.kopia-create = {
      description = "Backup to kopia repository";
      startAt = cfg.interval;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kopia}/bin/kopia snapshot create --config-file ${config.sops.secrets.kopia_connection_config.path} --no-persist-credentials --no-use-keyring /";
        EnvironmentFile = config.sops.secrets.kopia_environment.path;
        Nice = 19;
        IOSchedulingPriority = 7;
        CPUSchedulingPolicy = "batch";

        User = "root";

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
        ProtectProc = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        CapabilityBoundingSet = "CAP_DAC_OVERRIDE";
      };
    };
  };
}
