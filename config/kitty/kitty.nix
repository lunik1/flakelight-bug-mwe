{ config, lib, pkgs, ... }:

{
  enable = true;
  font = {
    name = "Myosevka Light";
    package = pkgs.lunik1-nur.myosevka.mono;
    size = 11.0;
  };
  theme = "Gruvbox Dark";
  shellIntegration.enableZshIntegration = true;
  settings =
    {
      bold_font = "Myosevka Semibold";
      italic_font = "Myosevka Light Italic";
      bold_italic_font = "Myosevka Semibold Italic";

      # linux_display_server = "x11"; # for window decorations

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
    };
  keybindings = {
    "kitty_mod+'" = "detach_window ask";
  };
}
