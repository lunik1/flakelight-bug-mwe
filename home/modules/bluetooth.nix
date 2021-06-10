# Userspace Bluetooth management

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.bluetooth;
in {
  options.lunik1.system.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ blueman bluezFull ];
    lunik1.waybar.bluetoothModule = true;
    services.blueman-applet.enable = true;
  };
}
