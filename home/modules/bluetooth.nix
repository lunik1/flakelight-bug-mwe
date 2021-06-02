# Userspace Bluetooth management

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.bluetooth;
in {
  options.lunik1.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ blueman bluezFull ];

    lunik1.waybar.bluetoothModule = true;

    services.blueman-applet.enable = true;
  };
}
