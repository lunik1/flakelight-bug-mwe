# # File sync - MEGA and Syncthing

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ megacmd ];

  services = {
    syncthing = {
      enable = true;
      tray = false; # does not work on wayland
    };
  };

  systemd.user = {
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
}
