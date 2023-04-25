# Tools and settings for KDE systems

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.kde;
in {
  options.lunik1.home.kde.enable =
    lib.mkEnableOption "user KDE tools and settings";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      featherpad
      libsForQt5.ark
      libsForQt5.kcalc
      libsForQt5.krunner-symbols
      libsForQt5.okular
    ];

    services = {
      kdeconnect.enable = true;
      syncthing.tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };
  };
}
