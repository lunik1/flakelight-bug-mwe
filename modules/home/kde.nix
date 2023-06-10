# Tools and settings for KDE systems

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.kde;
in
{
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

    programs.kitty = {
      enable = true;
      font = {
        name = "Myosevka Light";
        package = pkgs.myosevka;
        size = 11.0;
      };
      shellIntegration.enableZshIntegration = true;
      settings =
        let gruvbox = import ../../resources/colourschemes/gruvbox.nix;
        in
        rec {
          cursor_blink_interval = "0.5";
          cursor_stop_blinking_after = 15;
          enable_audio_bell = false;
          scrollback_lines = 5000;
          scrollback_fill_enlarged_window = true;
          remember_window_size = false;
          disable_ligatures = "always";
          symbol_map = "U+F0000-U+F0000 Material Design Icons";
          touch_scroll_multiplier = 3;
          mouse_hide_wait = 0;
          input_delay = 1;
          repaint_delay = 8;
          tab_bar_style = "powerline";
          tab_switch_strategy = "right";
          tab_bar_min_tabs = 1;
          tab_bar_edge = "top";

          foreground = gruvbox.dark.fg;
          background = gruvbox.dark.bg;
          color0 = gruvbox.dark.black.normal;
          color1 = gruvbox.dark.red.normal;
          color2 = gruvbox.dark.green.normal;
          color3 = gruvbox.dark.yellow.normal;
          color4 = gruvbox.dark.blue.normal;
          color5 = gruvbox.dark.purple.normal;
          color6 = gruvbox.dark.cyan.normal;
          color7 = gruvbox.dark.white.normal;
          color8 = gruvbox.dark.black.bright;
          color9 = gruvbox.dark.red.bright;
          color10 = gruvbox.dark.green.bright;
          color11 = gruvbox.dark.yellow.bright;
          color12 = gruvbox.dark.blue.bright;
          color13 = gruvbox.dark.purple.bright;
          color14 = gruvbox.dark.cyan.bright;
          color15 = gruvbox.dark.white.bright;
          selection_foreground = background;
          selection_background = foreground;
          url_color = gruvbox.dark.orange.normal;
          cursor = foreground;
        };
      keybindings = {
        "kitty_mod+'" = "detach_window ask";
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
