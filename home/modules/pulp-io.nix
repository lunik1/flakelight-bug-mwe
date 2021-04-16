# Printing and scanning

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome3.simple-scan
    system-config-printer
  ];
}
