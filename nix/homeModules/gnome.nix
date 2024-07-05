# Tools and settings for GNOME systems

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.gnome;
in
{
  options.lunik1.home.gnome.enable = lib.mkEnableOption "user GNOME tools and settings";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.lunik1.home.kde.enable;
        message = "Can only enable GNOME or KDE";
      }
    ];

    home.packages = with pkgs; [ mission-center ];

    programs = {
      firefox = {
        profiles.corin.settings = {
          "mousewheel.min_line_scroll_amount" = 70;
        };
      };
      kitty = lib.mkMerge [
        ((import ../../config/kitty/kitty.nix) { inherit config lib pkgs; })
        {
          settings.linux_display_server = "x11"; # for window decorations
        }
      ];
      zsh.shellAliases = {
        open = "gio open";
      };
    };

    services = {
      syncthing.tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };

    # disable gnome-keyring's ssh agent
    xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
      ${lib.fileContents "${pkgs.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
        Hidden=true
    '';
  };
}
