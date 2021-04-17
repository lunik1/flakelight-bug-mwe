{ fontPkg, gruvbox }:

{
  enable = true;
  font = {
    name = "Myosevka";
    package = fontPkg;
  };
  settings = rec {
    font_size = "13.0";
    cursor_blink_interval = "0.5";
    cursor_stop_blinking_after = 15;
    focus_follows_mouse = true;
    enable_audio_bell = false;
    remember_window_size = false;
    force_ltr = "true";
    disable_ligatures = "always";
    symbol_map = "U+F0000-U+F0000 Material Design Icons";
    touch_scroll_multiplier = 3;
    mouse_hide_wait = 0;
    input_delay = 1;

    # Colors
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
    # Clipboard
    "kitty_mod+v" = "paste_from_clipboard";
    "kitty_mod+s" = "paste_from_selection";
    "kitty_mod+c" = "copy_to_clipboard";
    "shift+insert" = "paste_from_selection";
    "kitty_mod+o" = "pass_selection_to_program";
    # Scrolling
    "kitty_mod+up" = "scroll_line_up";
    "kitty_mod+down" = "scroll_line_down";
    "kitty_mod+k" = "scroll_line_up";
    "kitty_mod+j" = "scroll_line_down";
    "ctrl+s whift+page_up" = "scroll_page_up";
    "kitty_mod+page_down" = "scroll_page_down";
    "kitty_mod+home" = "scroll_home";
    "kitty_mod+end" = "scroll_end";
    "kitty_mod+h" = "show_scrollback";
    # Window management (diabled)
    "kitty_mod+enter" = "no_op";
    "kitty_mod+n" = "new_os_window";
    "kitty_mod+w" = "no_op";
    "kitty_mod+]" = "no_op";
    "kitty_mod+[" = "no_op";
    "kitty_mod+f" = "no_op";
    "kitty_mod+b" = "no_op";
    "kitty_mod+`" = "no_op";
    "kitty_mod+1" = "no_op";
    "kitty_mod+2" = "no_op";
    "kitty_mod+3" = "no_op";
    "kitty_mod+4" = "no_op";
    "kitty_mod+5" = "no_op";
    "kitty_mod+6" = "no_op";
    "kitty_mod+7" = "no_op";
    "kitty_mod+8" = "no_op";
    "kitty_mod+9" = "no_op";
    "kitty_mod+0" = "no_op";
    # Tab management (disabled)
    "kitty_mod+right" = "no_op";
    "kitty_mod+left" = "no_op";
    "kitty_mod+t" = "no_op";
    "kitty_mod+q" = "no_op";
    "kitty_mod+l" = "no_op";
    "kitty_mod+." = "no_op";
    "kitty_mod+," = "no_op";
    # Misc.
    "kitty_mod+equal" = "change_font_size all +0.5";
    "kitty_mod+minus" = "change_font_size all -0.5";
    "kitty_mod+backspace" = "change_font_size all 0";
    "kitty_mod+f11" = "no_op";
    "kitty_mod+f10" = "no_op";
    "kitty_mod+u" = "input_unicode_character";
  };
}
