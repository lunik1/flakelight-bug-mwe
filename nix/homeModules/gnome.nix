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

    home.packages = with pkgs; [
      mission-center
    ];

    programs = {
      firefox = {
        profiles.corin.settings = {
          "mousewheel.min_line_scroll_amount" = 70;
        };
      };
      ghostty = {
        enable = true;
        enableZshIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        settings =
          {
            font-family = [
              "Myosevka"
              "JuliaMono"
            ];
            font-codepoint-map = "U+E000-U+E00A,U+EA60-U+EBEB,U+E0A0-U+E0C8,U+E0CA,U+E0CC-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6B1,U+E700-U+E7C5,U+F000-U+F2E0,U+F300-U+F372,U+F400-U+F532,U+F0001-U+F1AF0=Symbols Nerd Font Mono";
            font-size = 12;
            font-thicken = true;
            gtk-single-instance = true;
            shell-integration = "zsh";
            theme = "GruvboxDark";
            palette = [
              "0=#665c54"
            ];
          }
          // lib.optionalAttrs pkgs.stdenv.isDarwin {
            macos-icon = "custom-style";
            macos-icon-frame = "beige";
            macos-icon-ghost-color = "#EBDBB2";
            macos-option-as-alt = "left";
            macos-titlebar-style = "native";
          };
      };
      kitty = lib.mkMerge [
        ((import ../../config/kitty/kitty.nix) { inherit config lib pkgs; })
        {
          settings.linux_display_server = "wayland"; # for window decorations
        }
      ];
      zsh.shellAliases = {
        open = "gio open";
      };
    };

    # disable gnome-keyring's ssh agent
    xdg = {
      configFile = {
        "autostart/gnome-keyring-ssh.desktop".text = ''
          ${lib.fileContents "${pkgs.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
            Hidden=true
        '';
      };
      mimeApps = {
        enable = true;
        defaultApplications = {
          "image/avif" = [ "org.gnome.Loupe.desktop" ];
          "image/bmp" = [ "org.gnome.Loupe.desktop" ];
          "image/gif" = [ "org.gnome.Loupe.desktop" ];
          "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
          "image/png" = [ "org.gnome.Loupe.desktop" ];
          "image/tiff" = [ "org.gnome.Loupe.desktop" ];
          "image/vnd.microsoft.icon" = [ "org.gnome.Loupe.desktop" ];
          "image/webp" = [ "org.gnome.Loupe.desktop" ];

          "application/zip" = "org.gnome.FileRoller.desktop";
        };
      };
    };
  };
}
