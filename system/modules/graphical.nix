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
      enableDefaultFonts = true;
      # Needed fonts should be installed by home configuration
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
        defaultFonts.sansSerif = [ "Myosevka Etoile" ];
        defaultFonts.emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
