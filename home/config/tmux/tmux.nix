{ tmuxPlugins }:

{
  enable = true;
  baseIndex = 1;
  clock24 = true;
  keyMode = "vi";
  newSession = true;
  prefix = "C-a";
  terminal = "tmux-256color";
  plugins = [
    # tmuxPlugins.tmux-fzf
    tmuxPlugins.gruvbox
    tmuxPlugins.resurrect
    {
      plugin = tmuxPlugins.continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '20' # minutes
      '';
    }
    {
      plugin = tmuxPlugins.tilish;
      extraConfig = ''
        set -g @tilish-default 'main-vertical'
        set -g @tilish-easymode 'on'
        set -g @tilish-prefix 'C-\'
        set -g @tilish-dmenu 'on'
      '';
    }
    {
      plugin = tmuxPlugins.sysstat;
      extraConfig = ''
        set -g status-right "#{sysstat_cpu} | #{sysstat_mem} | #{sysstat_swap} | #{sysstat_loadavg} | #[fg=blue]#(echo $USER)#[default]@#H"
      '';
    }
  ];
  extraConfig = ''
    # Enable mouse
    set -g mouse
    set -g mouse on

    # horizontal splits
    unbind-key |
    bind-key | split-window -h

    # vertical splits
    unbind-key _
    bind-key _ split-window

    # true color
    set-option -ga terminal-overrides ",xterm-kitty:Tc"

    # fix cursor shape in neovim
    set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'

    # swapping panes with arrow keys
    unbind-key ^Left
    bind-key ^Left swap-pane -U
    unbind-key ^Right
    bind-key ^Right swap-pane -D
    unbind-key ^Up
    bind-key ^Up swap-pane -U
    unbind-key ^Down
    bind-key ^Down swap-pane -
  '';
}
