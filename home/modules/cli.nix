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
        bind.dnsutils
        btop
        comma
        croc
        duf
        emv
        eternal-terminal
        fast-cli
        fd
        ffmpeg-full
        fontconfig
        imagemagick
        pb_cli
        pgcli
        kopia
        libarchive
        lrzip
        lz4
        ncdu
        p7zip
        parallel
        parted
        psmisc
        ranger
        rename
        ripgrep
        rmlint
        rsync
        sd
        smartmontools
        streamlink
        stress-ng
        tealdeer
        unrar
        unzip
        wget
        xfsdump
        xxHash
        yt-dlp
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
          continue = true;
          file-allocation = "falloc";
          max-connection-per-server = 16;
          min-split-size = "8M";
          no-file-allocation-limit = "8M";
          on-download-complete = "exit";
          split = 32;
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
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv = { enable = true; };
      };
      htop = {
        enable = true;
        settings = import ../config/htop/htop.nix { inherit config; };
      };
      lesspipe.enable = true;
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
          conf = "$HOME/nix-config";
          code = "$HOME/code";
        };
        initExtraFirst = ''
          source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
          source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        '';
        initExtra = ''
          xsource ${../config/zsh/zshrc.local}
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

    systemd.user = {
      services = {
        nix-index = {
          Unit.Description = "nix-locate index update";

          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.nix-index}/bin/nix-index";
            Nice = 19;
            IOSchedulingPriority = 7;
            CPUSchedulingPolicy = "batch";

            KeyringMode = "private";
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "full";
            RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            SystemCallFilter = "@system-service";
          };
        };
        tldr = {
          Unit.Description = "tldr cache update";

          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.tealdeer}/bin/tldr --update";
            Nice = 19;
            IOSchedulingPriority = 7;
            CPUSchedulingPolicy = "batch";

            KeyringMode = "private";
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "full";
            RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            SystemCallFilter = "@system-service";
          };
        };
      };
      timers = {
        nix-index = {
          Unit = { Description = "nix-locate cache update"; };

          Timer = {
            OnCalendar = "*-*-* 00:00";
            Persistent = true;
            Unit = "tldr.service";
          };

          Install = { WantedBy = [ "timers.target" ]; };
        };
        tldr = {
          Unit = { Description = "tldr cache update"; };

          Timer = {
            OnCalendar = "*-*-* 00:00";
            Persistent = true;
            Unit = "tldr.service";
          };

          Install = { WantedBy = [ "timers.target" ]; };
        };
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
        "btop.conf" = {
          text = (builtins.readFile ../config/btop/btop.conf)
          # Need to get colour theme location from package
            + ''
              color_theme = ${pkgs.btop}/share/btop/themes/gruvbox_dark.theme
            ''
            # bpytop will crash if it tries to access /sys/class/power_supply
            # in vpsAdminOS
            + lib.optionalString config.lunik1.home.vpsAdminOs ''
              show_battery=False
            '';
          target = "btop/btop.conf";
        };
        "neofetch" = {
          source = ../config/neofetch/config.conf;
          target = "neofetch/config.conf";
        };
        "rc.conf" = {
          source = ../config/ranger/rc.conf;
          target = "ranger/rc.conf";
        };
        "yt-dlp" = {
          source = ../config/yt-dlp/conf;
          target = "yt-dlp/config";
        };
      };
    };
  };
}
