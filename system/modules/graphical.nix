# Settings for graphical systems

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.graphical;
in {
  options.lunik1.system.graphical.enable =
    lib.mkEnableOption "graphical settings and programs";

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = true;
    gtk.iconCache.enable = true;

    services = {
      gpm.enable = true;

      dbus.packages = with pkgs; [ gnome3.dconf ];
    };

    fonts = {
      fonts = with pkgs; [
        font-awesome-ttf
        material-design-icons
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        sarasa-gothic
        source-code-pro
        source-sans-pro
        source-serif-pro
        julia-mono
        # TODO: iosevka
      ];
      enableDefaultFonts = true;
      fontconfig = {
        defaultFonts.monospace = [
          "Source Code Pro"
          "Sarasa Fixed CL"
          "Sarasa Fixed HC"
          "Sarasa Fixed TC"
          "Sarasa Fixed J"
          "Sarasa Fixed K"
          "Julia Mono"
          "all-the-icons"
          "file-icons"
          "Material Icons"
          "Font Awesome 5 Free"
          "Font Awesome 5 Brands"
        ];
        defaultFonts.serif = [
          "Source Serif Pro"
          "all-the-icons"
          "file-icons"
          "Material Icons"
          "Font Awesome 5 Free"
          "Font Awesome 5 Brands"
        ];
        defaultFonts.sansSerif = [
          "Source Sans Pro"
          "all-the-icons"
          "file-icons"
          "Material Icons"
          "Font Awesome 5 Free"
          "Font Awesome 5 Brands"
        ];
        defaultFonts.emoji = [
          "Noto Color Emoji"
          "Material Icons"
          "Font Awesome 5 Free"
          "Font Awesome 5 Brands"
        ];
      };
    };
  };
}
