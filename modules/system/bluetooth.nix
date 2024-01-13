# System bluetooth configuration

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.bluetooth;
in {
  options.lunik1.system.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    # KDE/GNOME has its own applet
    services.blueman.enable = !(config.lunik1.system.kde.enable || config.lunik1.system.gnome.enable);

    # passwordless access to rfkill without sudo so bluetooth can be toggled
    security.sudo.extraRules = [{
      groups = [ "wheel" ];
      commands = [{
        command = "/run/current-system/sw/bin/rfkill";
        options = [ "NOPASSWD" ];
      }];
    }];
  };
}
