{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.cli;
in {
  options.lunik1.home.cli.enable = lib.mkEnableOption "CLI programs";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        aspell
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.en-science
        bat-extras.batgrep
        borgbackup
        bind.dnsutils
        bpytop
        cmake
        duf
        emv
        eternal-terminal
        fast-cli
        fd
        ffmpeg-full
        fontconfig
        glances
        imagemagick
        ix
        libarchive
        libwebp
        lrzip
        magic-wormhole
        ncdu
        neofetch
        nix-zsh-completions
        p7zip
        parallel
        parted
        psmisc
        ranger
        rename
        ripgrep
        rmlint
        rsync
        smartmontools
        streamlink
        stress-ng
        tealdeer
        unrar
        unzip
        wget
        youtube-dl
        zsh-completions

        ripgrep-all # heavy dependencies, optional/own module?
      ];

      sessionVariables = { ET_NO_TELEMETRY = "1"; };

      file = {
        ".aspell.conf" = {
          text = ''
            dict-dir ${config.home.homeDirectory}/.nix-profile/lib/aspell
          '';
          target = ".aspell.conf";
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
        extraConfig = builtins.readFile "${pkgs.LS_COLORS}/LS_COLORS";
      };
      htop = {
        enable = true;
        settings = import ../config/htop/htop.nix { inherit config; };
      };
      nix-index = {
        enable = true;
        enableZshIntegration = true;
      };
      tmux = import ../config/tmux/tmux.nix { tmuxPlugins = pkgs.tmuxPlugins; };
      fzf = rec {
        enable = true;
        enableFishIntegration = false;
        changeDirWidgetCommand = "${pkgs.fd}/bin/fd -H --type directory";
        defaultCommand = "${pkgs.fd}/bin/fd -H -E '.git' --type file";
        fileWidgetCommand = defaultCommand;
      };
      zsh = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        history = { size = 50000; };
        dirHashes = {
          conf = "$HOME/config";
          code = "$HOME/code";
        };
        initExtraFirst = ''
          source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
          source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        '';
        initExtra = ''
          xsource ${../config/zsh/.zshrc.local}
        '';
        envExtra = ''
          export PATH=$HOME/bin:$HOME/.cargo/bin/:$PATH
        '';
        # Make TRAMP and zsh play nice
        # https://www.emacswiki.org/emacs/TrampMode#h5o-9
        profileExtra = ''
          if [[ "$TERM" == "tramp" ]]
          then
            . "/home/corin/.nix-profile/etc/profile.d/hm-session-vars.sh"
            unsetopt zle
            unsetopt prompt_cr
            unsetopt prompt_subst
            unset zle_bracketed_paste
            unset RPROMPT
            unset RPS1
            unsetopt rcs
            PS1="$ "
            if whence -w precmd >/dev/null; then
                unfunction precmd
            fi
            if whence -w preexec >/dev/null; then
                unfunction preexec
            fi
            PS1='$ '
          fi
        '';
      };
    };

    xdg = {
      enable = true;
      dataFile = {
        "zsh_cheatsheet" = {
          source = ../data/zsh/zsh_cheatsheet.md;
          target = "zsh/zsh_cheatsheet.md";
        };
      };
      configFile = {
        "bpytop.conf" = {
          source = ../config/bpytop/bpytop.conf;
          target = "bpytop/bpytop.conf";
        };
        "neofetch" = {
          source = ../config/neofetch/config.conf;
          target = "neofetch/config.conf";
        };
        "rc.conf" = {
          source = ../config/ranger/rc.conf;
          target = "ranger/rc.conf";
        };
      };
    };
  };
}
