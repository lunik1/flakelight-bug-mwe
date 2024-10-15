let
  gruvbox = import ../../resources/colourschemes/gruvbox.nix;
in
{
  font = "Myosevka 12";

  notification-error-bg = gruvbox.dark.bg;
  notification-error-fg = gruvbox.dark.red.bright;
  notification-warning-bg = gruvbox.dark.bg;
  notification-warning-fg = gruvbox.dark.yellow.bright;
  notification-bg = gruvbox.dark.bg;
  notification-fg = gruvbox.dark.green.bright;

  completion-bg = gruvbox.dark.bg0_s;
  completion-fg = gruvbox.dark.fg;
  completion-group-bg = gruvbox.dark.bg1;
  completion-group-fg = gruvbox.dark.gray;
  completion-highlight-bg = gruvbox.dark.blue.bright;
  completion-highlight-fg = gruvbox.dark.bg0_s;

  index-bg = gruvbox.dark.bg0_s;
  index-fg = gruvbox.dark.fg;
  index-active-bg = gruvbox.dark.blue.bright;
  index-active-fg = gruvbox.dark.bg0_s;

  inputbar-bg = gruvbox.dark.bg;
  inputbar-fg = gruvbox.dark.fg;

  statusbar-bg = gruvbox.dark.bg0_s;
  statusbar-fg = gruvbox.dark.fg;

  highlight-color = "rgba(214, 93, 14, 0.5)";
  highlight-active-color = "rgba(250, 189, 47, 0.5)";

  default-bg = gruvbox.dark.bg0_h;
  default-fg = gruvbox.dark.fg;
  render-loading = true;
  render-loading-bg = gruvbox.dark.bg;
  render-loading-fg = gruvbox.dark.fg;

  # C-r
  recolor-lightcolor = gruvbox.dark.bg;
  recolor-darkcolor = gruvbox.dark.fg;
  # recolor = true;
  # set recolor-keephue             true      # keep original color

  # use CLIPBOARD, not PRIMARY
  selection-clipboard = "clipboard";
}
