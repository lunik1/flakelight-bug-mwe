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
      default = "00:00";
      type = str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.kopia-create = {
      description = "Backup to kopia webdav server";
      startAt = cfg.interval;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kopia}/bin/kopia snapshot create /";
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
        # RestrictAddressFamilies = "none";
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
