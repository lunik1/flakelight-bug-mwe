# Userspace Bluetooth management

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.bluetooth;
in
{
  options.lunik1.home.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [ bluez ]
      ++ lib.optionals (!(config.lunik1.home.kde.enable || config.lunik1.home.gnome.enable)) [ blueman ];
    lunik1.home.waybar.bluetoothModule = true;

    # KDE/GNOME has its own applet
    services.blueman-applet.enable =
      !(config.lunik1.home.kde.enable || config.lunik1.home.gnome.enable);
  };
}
