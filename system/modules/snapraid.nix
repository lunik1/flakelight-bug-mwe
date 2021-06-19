# SnapRAID configuration

{ config, lib, pkgs, ... }:

with lib;
let cfg = config.lunik1.system.snapraid;
in {
  options.lunik1.system.snapraid = with types; {
    enable = mkEnableOption "SnapRAID";
    dataDisks = mkOption {
      default = { };
      description = "SnapRAID data disks.";
      type = attrsOf str;
    };
    parityFiles = mkOption {
      default = [ ];
      description = "SnapRAID parity files.";
      type = listOf str;
    };
    contentFiles = mkOption {
      default = [ ];
      description = "SnapRAID content list files.";
      type = listOf str;
    };
    exclude = mkOption {
      default = [ ];
      description = "SnapRAID exclude directives.";
      type = listOf str;
    };
    touchBeforeSync = mkOption {
      default = true;
      description =
        "Whether <command>snapraid touch</command> should be run before <command>snapraid sync</command>";
      type = bool;
    };
    syncInterval = mkOption {
      default = "13:00";
      description = "How often to run <command>snapraid sync</command>";
      type = str;
    };
    scrubInterval = mkOption {
      default = "Mon *-*-* 14:00:00";
      description = "How often to run <command>snapraid scrub</command>";
      type = str;
    };
    extraConfig = mkOption {
      default = "";
      description = "Extra config options for SnapRAID.";
      type = lines;
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = builtins.length cfg.parityFiles <= 6;
      message = "You can have no more than six parity files";
    }];

    environment = {
      systemPackages = with pkgs; [ snapraid ];

      etc."snapraid.conf" = {
        text = with cfg;
          let
            mkPrepend = pre: s: pre + s;
            prependData = mkPrepend "data ";
            prependContent = mkPrepend "content ";
            prependExclude = mkPrepend "exclude ";
          in concatStringsSep "\n" (map prependData
            ((mapAttrsToList (name: value: name + " " + value)) dataDisks)
            ++ zipListsWith (a: b: a + b)
            ([ "parity " ] ++ map (i: toString i + "-parity ") (range 2 6))
            parityFiles ++ map prependContent contentFiles
            ++ map prependExclude exclude ++ [ ]);
      };
    };

    systemd.timers = with cfg; {
      snapraid-scrub = {
        description = "SnapRAID scrub timer";
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = scrubInterval;
      };
      snapraid-sync = {
        description = "SnapRAID sync timer";
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = syncInterval;
      };
    };

    systemd.services = {
      snapraid-scrub = {
        description = "Scrub the SnapRAID array";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.snapraid}/bin/snapraid scrub";
          Nice = "15";
          IOSchedulingClass = "best-effort";
          IOSchedulingPriority = "6";
        };
        unitConfig.After = "snapraid-sync.service";
      };
      snapraid-sync = {
        description = "Synchronize the state of the SnapRAID array";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.snapraid}/bin/snapraid sync";
          Nice = "15";
          IOSchedulingClass = "best-effort";
          IOSchedulingPriority = "6";
        } // optionalAttrs cfg.touchBeforeSync {
          ExecStartPre = "${pkgs.snapraid}/bin/snapraid touch";
        };
      };
    };
  };
}
