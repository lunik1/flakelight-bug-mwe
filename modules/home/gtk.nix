# GTK settings

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.gtk;
in {
  options.lunik1.home.gtk.enable = lib.mkEnableOption "GTK settings";

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      font = {
        package = pkgs.lunik1-nur.myosevka.aile;
        name = "Myosevka Aile 11";
      };
      iconTheme = {
        package = pkgs.qogir-theme;
        name = "Qogir";
      };
      theme = {
        package = pkgs.qogir-icon-theme;
        name = "Qogir";
      };
      gtk2.extraConfig = ''
        gtk-error-bell = 0
      '';
      gtk3.extraConfig.gtk-error-bell = 0;
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style = {
        package = pkgs.arc-kde-theme;
        name = "Arc";
      };
    };
  };
}
