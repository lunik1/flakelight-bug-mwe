# Userspace Bluetooth management

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ blueman bluezFull ];

  waybar.bluetoothModule = true;
}
