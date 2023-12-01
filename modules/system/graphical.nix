# Settings for graphical systems

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.graphical;
in {
  options.lunik1.system.graphical.enable =
    lib.mkEnableOption "graphical settings and programs";

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = true;
    gtk.iconCache.enable = true;

    environment.etc.xsettingsd = {
      target = "xdg/xsettingsd/xsettingsd.conf";
      text = ''
        Xft/Hinting ${
          if config.fonts.fontconfig.hinting.enable then "1" else "0"
        }
        Xft/Antialias ${if config.fonts.fontconfig.antialias then "1" else "0"}
        Xft/RGBA "${config.fonts.fontconfig.subpixel.rgba}"
      '';
    };

    services = {
      colord.enable = true;
      gpm.enable = true;
      dbus.packages = with pkgs; [ dconf ];
    };

    services.xserver.layout = "gb";

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        julia-mono
        material-design-icons
        noto-fonts-emoji
        sarasa-gothic
        myosevka
        myosevka-aile
        myosevka-etoile
      ];
      fontconfig = {
        defaultFonts.monospace = [
          "Myosevka"
          "Sarasa Fixed CL"
          "Sarasa Fixed HC"
          "Sarasa Fixed TC"
          "Sarasa Fixed J"
          "Sarasa Fixed K"
          "Julia Mono"
          "Material Icons"
        ];
        defaultFonts.serif = [ "Myosevka Etoile" ];
        defaultFonts.sansSerif = [ "Myosevka Aile" ];
        defaultFonts.emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
