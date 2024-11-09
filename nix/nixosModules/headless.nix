# Module for headless systems

{ config, lib, ... }:

let
  cfg = config.lunik1.system.headless;
in
{
  options.lunik1.system.headless.enable = lib.mkEnableOption "headless";

  config = lib.mkIf cfg.enable {
    environment.stub-ld.enable = false;

    documentation.nixos.enable = false;

    fonts.fontconfig.enable = false;

    xdg = {
      autostart.enable = false;
      icons.enable = false;
      menus.enable = false;
      mime.enable = false;
      sounds.enable = false;
    };

    systemd = {
      enableEmergencyMode = false;

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';

      watchdog = {
        runtimeTime = "30s";
        rebootTime = "10s";
        kexecTime = "1m";
      };
    };
  };
}
