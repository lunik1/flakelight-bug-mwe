{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      bat-extras.batgrep
      borgbackup
      bpytop
      chezmoi
      cmake
      duf
      eternal-terminal
      fast-cli
      fd
      ffmpeg-full
      imagemagick
      libarchive
      lrzip
      magic-wormhole
      ncdu
      neofetch
      p7zip
      pandoc
      parallel
      parted
      psmisc
      ranger
      ripgrep
      rmlint
      rsync
      stress-ng
      tealdeer
      unrar
      unzip
      wget
      youtube-dl

      ripgrep-all # heavy dependencies, optional/own module?
    ];

    file = {
      ".zshrc.local" = {
        source = ../config/zsh/.zshrc.local;
        target = ".zshrc.local";
      };
    };

    sessionPath = [ "~/bin" ];
  };

  programs = {
    aria2 = {
      enable = true;
      settings = {
        max-connection-per-server = 4;
        continue = true;
      };
    };
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
        pager = "less -FR";
      };
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = builtins.readFile (pkgs.LS_COLORS.outPath + "/LS_COLORS");
    };
    htop = {
      enable = true;
      fields = [
        "PID"
        "USER"
        # "PRIORITY"
        "NICE"
        "IO_PRIORITY"
        # "IO_WRITE_RATE"
        # "IO_READ_RATE"
        "IO_RATE"
        "STATE"
        "NLWP"
        "PERCENT_CPU"
        "PERCENT_MEM"
        # "RCHAR"
        # "WCHAR"
        "TIME"
        "OOM"
        "COMM"
      ];
      cpuCountFromZero = true;
      hideThreads = true;
      hideUserlandThreads = true;
      highlightBaseName = true;
      meters = {
        left = [
          "AllCPUs"
          "Blank"
          {
            kind = "CPU";
            mode = 3;
          }
          "Blank"
          "LoadAverage"
          "Tasks"
        ];
        right = [
          {
            kind = "Memory";
            mode = 3;
          }
          {
            kind = "Memory";
            mode = 2;
          }
          "Blank"
          {
            kind = "Swap";
            mode = 3;
          }
          {
            kind = "Swap";
            mode = 2;
          }
          "Blank"
          "Uptime"
        ];
      };
      showProgramPath = false;
      updateProcessNames = true;
      vimMode = true;
    };
    ssh = import ../config/ssh/config.nix;
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      keyMode = "vi";
      newSession = true;
      prefix = "C-a";
      terminal = "tmux-256color";
      plugins = with pkgs; [
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
        bind-key ^Down swap-pane -D
              '';
    };
    fzf = rec {
      enable = true;
      enableFishIntegration = false;
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd -H --type directory";
      defaultCommand = "${pkgs.fd}/bin/fd -H -E '.git' --type file";
      fileWidgetCommand = defaultCommand;
    };
    zsh = {
      enable = true;
      enableVteIntegration = true;
      history = { size = 50000; };
      initExtraFirst = ''
        source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
      envExtra = ''
        export PATH=$HOME/bin:$HOME/.cargo/bin/:$PATH
      '';
    };
  };
}
