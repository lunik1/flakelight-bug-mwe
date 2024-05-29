# # File sync - MEGA and Syncthing

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home;
in
{
  options.lunik1.home = {
    megacmd.enable = lib.mkEnableOption "MEGAcmd";
    megasync.enable = lib.mkEnableOption "MEGAsync";
    syncthing.enable = lib.mkEnableOption "syncthing";
  };

  config = {
    home.packages =
      with pkgs;
      lib.optional cfg.megacmd.enable megacmd ++ lib.optional cfg.megasync.enable megasync;

    services = lib.mkIf cfg.syncthing.enable {
      syncthing = {
        enable = true;
      };
    };

    systemd.user = lib.mkIf cfg.megacmd.enable {
      startServices = "sd-switch";
      services = {
        mega-cmd-server = {
          Unit = {
            Description = "MEGAcmd server";
            After = "network.target";
          };
          Install.WantedBy = [ "default.target" ];
          Service = {
            Environment = [ "HOME=${config.home.homeDirectory}" ];
            ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
            Restart = "on-failure";
            ProtectSystem = "full";
            Nice = 10;
            CPUSchedulingPolicy = "batch";
            IOSchedulingClass = "best-effort";
            IOSchedulingPriority = 5;
          };
        };
      };
    };
  };
}
