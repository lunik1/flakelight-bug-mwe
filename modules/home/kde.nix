# Tools and settings for KDE systems

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.kde;
in
{
  options.lunik1.home.kde.enable =
    lib.mkEnableOption "user KDE tools and settings";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.lunik1.home.gnome.enable;
        message = "Can only enable GNOME or KDE";
      }
    ];

    home.packages = with pkgs; [
      featherpad
      libsForQt5.ark
      libsForQt5.kcalc
      libsForQt5.krunner-symbols
      libsForQt5.okular
      ungoogled-chromium
    ];

    programs = {
      kitty = ((import ../../config/kitty/kitty.nix) { inherit config lib pkgs; });
      mpv.config = {
        drag-and-drop = "append";
        gpu-context = "x11vk";
      };
    };

    services = {
      kdeconnect.enable = true;
      syncthing.tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };
  };
}
