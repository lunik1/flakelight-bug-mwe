# # File sync - MEGA and Syncthing

{ config, lib, pkgs, ... }:

let cfg = config.lunik1;
in {
  options.lunik1 = {
    megacmd.enable = lib.mkEnableOption "MEGAcmd";
    syncthing.enable = lib.mkEnableOption "syncthing";
  };

  config = {
    home.packages = with pkgs; lib.mkIf cfg.megacmd.enable [ megacmd ];

    services = lib.mkIf cfg.syncthing.enable {
      syncthing = {
        enable = true;
        tray = false; # does not work on wayland
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
            PrivateTmp = true;
            ProtectSystem = "full";
            Nice = 10;
            IOSchedulingClass = "best-effort";
            IOSchedulingPriority = 5;
          };
        };
      };
    };
  };
}
