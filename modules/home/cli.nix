{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.cli;
in {
  options.lunik1.home.cli.enable = lib.mkEnableOption "CLI programs";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
        bat-extras.batgrep
        comma
        copier
        croc
        duf
        emv
        eternal-terminal
        fast-cli
        fd
        ffmpeg-full
        file
        fontconfig
        imagemagick
        pb_cli
        kopia
        libarchive
        lrzip
        lz4
        ncdu
        nix-tree
        p7zip
        parallel
        parted
        psmisc
        q
        ranger
        rename
        ripgrep
        rmlint
        rsync
        sd
        smartmontools
        streamlink
        stress-ng
        unrar
        unzip
        webwormhole
        wget
        xfsdump
        xxHash
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
        xcompose = {
          # Some applications (emacs, firefox, …) seem to ignore include
          # directives, so let's just concatenate all the files together
          text = with pkgs.lunik1-nur;
            (builtins.readFile "${xcompose}/dotXCompose")
            + (builtins.readFile "${xcompose}/frakturcompose")
            + (builtins.readFile "${xcompose}/emoji.compose")
            + (builtins.readFile "${xcompose}/parens.compose")
            + (builtins.readFile "${xcompose}/maths.compose");
          target = ".XCompose";
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
      btop = {
        enable = true;
        settings = {
          theme_background = true;
          truecolor = true;
          force_tty = false;
          presets =
            "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
          rounded_corners = true;
          graph_symbol = "braille";
          graph_symbol_cpu = "default";
          graph_symbol_mem = "default";
          graph_symbol_net = "default";
          graph_symbol_proc = "default";
          shown_boxes = "cpu mem net proc";
          update_ms = 2000;
          proc_sorting = "cpu lazy";
          proc_reversed = false;
          proc_tree = false;
          proc_colors = true;
          proc_gradient = true;
          proc_per_core = true;
          proc_mem_bytes = true;
          proc_info_smaps = false;
          proc_left = true;
          cpu_graph_upper = "total";
          cpu_graph_lower = "total";
          cpu_invert_lower = true;
          cpu_single_graph = false;
          cpu_bottom = false;
          show_uptime = true;
          check_temp = true;
          cpu_sensor = "Auto";
          show_coretemp = true;
          cpu_core_map = "";
          temp_scale = "celsius";
          show_cpu_freq = true;
          clock_format = "%X";
          background_update = true;
          custom_cpu_name = "";
          disks_filter = "";
          mem_graphs = true;
          mem_below_net = true;
          show_swap = true;
          swap_disk = false;
          show_disks = true;
          only_physical = true;
          use_fstab = false;
          show_io_stat = true;
          io_mode = false;
          io_graph_combined = false;
          io_graph_speeds = "";
          net_download = 100;
          net_upload = 100;
          net_auto = true;
          net_sync = false;
          net_iface = "";
          show_battery = true;
          log_level = "DISABLED";
          color_theme = "${pkgs.btop}/share/btop/themes/gruvbox_dark.theme";
        }
        # btop will crash if it tries to access /sys/class/power_supply
        # in vpsAdminOS
        // lib.optionalAttrs config.lunik1.home.vpsAdminOs {
          show_battery = false;
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
        settings = import ../../config/htop/htop.nix { inherit config; };
      };
      lesspipe.enable = true;
      nix-index = {
        enable = true;
        enableZshIntegration = true;
      };
      tealdeer = {
        enable = true;
        settings.updates = {
          auto_update = true;
          auto_update_interval_hours = 24;
        };
      };
      tmux = import ../../config/tmux/tmux.nix { inherit (pkgs) tmuxPlugins; };
      fzf = rec {
        enable = true;
        enableFishIntegration = false;
        changeDirWidgetCommand = "${pkgs.fd}/bin/fd -H --type directory";
        defaultCommand = "${pkgs.fd}/bin/fd -H -E '.git' --type file";
        fileWidgetCommand = defaultCommand;
      };
      yt-dlp = {
        enable = true;
        settings = {
          embed-thumbnail = true;
          add-metadata = true;
          merge-output-format = "mkv";
          embed-subs = true;
          convert-subs = "ass";
          external-downloader = "${pkgs.aria2}/bin/aria2c";
        };
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
          xsource ${../../config/zsh/zshrc.local}
        '';
        envExtra = ''
          export PATH=$HOME/bin:$HOME/.cargo/bin/:$PATH

          if [[ "$TERM" == "foot" ]]
          then
            export COLORTERM="truecolor"
          fi
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
          source = ../../resources/zsh/zsh_cheatsheet.md;
          target = "zsh/zsh_cheatsheet.md";
        };
      };
      configFile = {
        "neofetch" = {
          source = ../../config/neofetch/config.conf;
          target = "neofetch/config.conf";
        };
        "rc.conf" = {
          source = ../../config/ranger/rc.conf;
          target = "ranger/rc.conf";
        };
      };
    };
  };
}
