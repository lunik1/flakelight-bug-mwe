{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.cli;
in
{
  options.lunik1.home.cli.enable = lib.mkEnableOption "CLI programs";

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          (aspellWithDicts (
            dicts: with dicts; [
              en
              en-computers
              en-science
            ]
          ))
          bat-extras.batgrep
          copier
          croc
          duf
          emv
          eternal-terminal
          ffmpeg-full
          file
          fontconfig
          ghostscript
          imagemagick
          libarchive
          lrzip
          lz4
          ncdu
          nix-tree
          p7zip
          parallel
          q
          rename
          ripgrep
          rmlint
          rsync
          sd
          streamlink
          stress-ng
          tree
          unar
          unzip
          kopia
          webwormhole
          wget
          xxHash
          yazi
          zsh-completions
        ]
        ++ lib.optionals stdenv.isLinux [
          cfspeedtest
          pb_cli
          parted
          psmisc
          smartmontools
          xfsdump
        ]
        ++ lib.optionals (stdenv.isLinux && stdenv.isx86_64) [ lunik1-nur.efficient-compression-tool ];

      sessionVariables = {
        ET_NO_TELEMETRY = "1";
        RSYNC_CHECKSUM_LIST = "xxh3 xxh128 xxh64 sha1 md5 md4 none";
        RSYNC_COMPRESS_LIST = "lz4 zstd zlibx zlib none";
        MANWIDTH = 80;
      };

      # Add a personal aspell dict if it does not already exist
      activation = {
        createAspellPersonalDictionary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -f ~/.aspell.en.pws ]
          then
            printf "personal_ws-1.1 en 0\n" > ~/.aspell.en.pws
          fi
        '';
      };

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
          text =
            with pkgs.lunik1-nur;
            (builtins.readFile "${xcompose}/dotXCompose")
            + (builtins.readFile "${xcompose}/frakturcompose")
            + (builtins.readFile "${xcompose}/emoji.compose")
            + (builtins.readFile "${xcompose}/parens.compose")
            + (builtins.readFile "${xcompose}/maths.compose");
          target = ".XCompose";
        };
        zprintrc = {
          text = "{:search-config? true}";
          target = ".zprintrc";
        };
      };

      sessionPath = [ "~/bin" ];
    };

    programs = {
      aria2 = {
        enable = true;
        settings =
          {
            continue = true;
            file-allocation = "falloc";
            max-connection-per-server = 16;
            min-split-size = "8M";
            no-file-allocation-limit = "8M";
            on-download-complete = "exit";
            split = 32;
          }
          // lib.optionalAttrs config.lunik1.home.wsl.enable {
            ca-certificate = "/etc/ssl/ca-bundle.pem"; # openSUSE location
          };
      };
      atuin = {
        enable = true;
        flags = [ "--disable-up-arrow" ];
        enableZshIntegration = true;
        settings = {
          dialect = "uk";
          update_check = false;
          sync_address = "https://atuin.lunik.one:443";
          sync_frequency = "15m";
          filter_mode_shell_up_key_binding = "host";
          style = "compact";
          show_preview = true;
          exit_mode = "return-query";
          history_filter = [
            "^ "
            "^export"
          ];
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
          presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
          rounded_corners = true;
          graph_symbol = "braille";
          graph_symbol_cpu = "default";
          graph_symbol_mem = "default";
          graph_symbol_net = "default";
          graph_symbol_proc = "default";
          shown_boxes = "cpu mem net proc gpu0";
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
        };
      };
      dircolors = {
        enable = true;
        enableZshIntegration = true;
        extraConfig = builtins.readFile "${pkgs.lunik1-nur.ls-colors}/share/ls-colors/LS_COLORS";
      };
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv = {
          enable = true;
        };
      };
      lesspipe.enable = true;
      nix-index = {
        enable = true;
        enableZshIntegration = true;
      };
      nix-index-database.comma.enable = true;
      tealdeer = {
        enable = true;
        settings.updates = {
          auto_update = true;
          auto_update_interval_hours = 24;
        };
      };
      tmux = import ../../config/tmux/tmux.nix { inherit (pkgs) tmuxPlugins; };
      fd.enable = true;
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
          netrc = true;
          external-downloader = "${pkgs.aria2}/bin/aria2c";
        };
      };
      zsh = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        history = {
          size = 50000;
        };
        dirHashes = {
          conf = "$HOME/nix-config";
          code = "$HOME/code";
        };
        initExtraFirst = ''
          source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
          source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        '';
        initExtra = ''
          source ${../../config/zsh/zshrc.local}
          source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
        '';
        envExtra = ''
          if [[ "$TERM" == "foot" ]]
          then
            export COLORTERM="truecolor"
          fi

          # read sops secrets
          # secrets
          [ -f "${config.sops.secrets.cachix_auth_token.path}" ] \
            && export CACHIX_AUTH_TOKEN=$(<"${config.sops.secrets.cachix_auth_token.path}")
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

    sops.secrets = {
      ssh_config = {
        path = ".ssh/config";
      };
      cachix_auth_token = { };
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
        "streamlink" = {
          target = "streamlink/config";
          text = ''
            player=mpv

            twitch-disable-ads
            twitch-low-latency
          '';
        };
      };
    };
  };
}
