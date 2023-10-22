# Userspace Bluetooth management

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.bluetooth;
in
{
  options.lunik1.home.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bluez
    ]
    ++ lib.optionals (!config.lunik1.home.kde.enable) [
      blueman
    ];
    lunik1.home.waybar.bluetoothModule = true;

    # KDE has its own applet
    services.blueman-applet.enable = !config.lunik1.home.kde.enable;
  };
}
