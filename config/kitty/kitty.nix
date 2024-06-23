{ pkgs, ... }:

{
  enable = true;
  font = {
    name = "Myosevka Light";
    package = pkgs.lunik1-nur.myosevka.mono;
    size = 11.0;
  };
  theme = "Gruvbox Dark";
  shellIntegration.enableZshIntegration = true;
  settings = {
    bold_font = "Myosevka Semibold";
    italic_font = "Myosevka Light Italic";
    bold_italic_font = "Myosevka Semibold Italic";

    # linux_display_server = "x11"; # for window decorations

    clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
    cursor_blink_interval = "0.5";
    cursor_stop_blinking_after = 15;
    enable_audio_bell = false;
    scrollback_lines = 5000;
    scrollback_fill_enlarged_window = true;
    remember_window_size = false;
    disable_ligatures = "always";
    symbol_map = "U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d4,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b1,U+e700-U+e7c5,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f532,U+f0001-U+f1af0 Symbols Nerd Font Mono";
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
