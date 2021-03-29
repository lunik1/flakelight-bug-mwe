{ pkgs, config, lib, ... }:

let
  gruvbox = import ./resources/colourschemes/gruvbox.nix;
  myosevka = pkgs.iosevka.override {
    privateBuildPlan = import resources/iosevka/myosevka.nix;
    set = "myosevka";
  };
  myosevka-aile = pkgs.iosevka.override {
    privateBuildPlan =
      (import resources/iosevka/myosevka-aile.nix) { inherit lib; };
    set = "myosevka-aile";
  };
in {
  home = {
    packages = with pkgs; [
      # Core utils (installed by defult on NixOS)
      acl
      bashInteractive
      bzip2
      coreutils-full
      cpio
      curl
      diffutils
      findutils
      gawk
      getconf
      getent
      gnugrep
      gnupatch
      gnused
      gnutar
      gzip
      less
      libcap
      mkpasswd
      nano
      netcat
      procps
      su
      time
      util-linux
      which
      xfce.thunar
      xz
      zstd

      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      bat-extras.batgrep
      bitwarden
      blueman
      borgbackup
      bpytop
      chezmoi
      cmake
      connman-gtk
      discord
      duf
      element-desktop
      eternal-terminal
      fast-cli
      fd
      ffmpeg-full
      gnome3.gucharmap
      gnome3.simple-scan
      hplip
      imagemagick
      libarchive
      libreoffice-fresh
      lrzip
      magic-wormhole
      megacmd
      ncdu
      nodejs
      opera
      p7zip
      pandoc
      parallel
      parted
      pavucontrol
      playerctl
      plex-media-player
      psmisc
      qdirstat
      ranger
      ripgrep
      ripgrep-all
      rmlint
      rsync
      shfmt
      skypeforlinux
      system-config-printer
      tealdeer
      teams
      thunderbird
      unrar
      unzip
      wev
      wget
      yarn
      youtube-dl

      # Git
      git-crypt

      # (Doom) Emacs
      glslang
      gnuplot
      graphviz
      shellcheck
      sqlite-interactive.bin

      # Games
      crawl
      crawlTiles
      # dwarf-fortress-packages.dwarf-fortress-full
      # freeciv
      # freeciv_gtk
      # freeciv_qt qt5.qtwayland
      openrct2
      # wesnoth

      # Dev
      # C/C++
      ccls
      # clang # collides with gcc
      clang-tools
      gcc

      # LaTeX
      texlab

      # Json
      jq
      nodePackages.vscode-json-languageserver-bin

      # Nix
      nixFlakes
      nixfmt
      nixpkgs-fmt

      # Python
      black
      poetry
      python-language-server
      python

      # Rust
      rustup
      rust-analyzer

      # Clojure
      babashka
      joker
      leiningen
      visualvm

      # Julia
      julia

      # Misc
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.yaml-language-server

      # Linters
      languagetool
      nixpkgs-fmt
      nodePackages.write-good
      proselint
      python37Packages.yamllint
      vale
      vim-vint

      # Fonts
      emacs-all-the-icons-fonts
      font-awesome-ttf
      julia-mono
      material-design-icons
      montserrat
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      sarasa-gothic
      source-code-pro
      source-sans-pro
      source-serif-pro
      myosevka
      myosevka-aile
      (iosevka.override {
        privateBuildPlan = import resources/iosevka/myosevka-proportional.nix;
        set = "myosevka-proportional";
      })
      (iosevka.override {
        privateBuildPlan =
          (import resources/iosevka/myosevka-etoile.nix) { inherit lib; };
        set = "myosevka-etoile";
      })
    ];
    sessionPath = [ "~/bin" ];
    sessionVariables = {
      EDITOR = "nvim";
      LIBVA_DRIVER_NAME = "iHD";
      MOZ_WEBRENDER = "1";
      XDG_CONFIG_HOME = "~/.config";
    };
  };

  programs = {
    aria2.enable = true;
    bat = {
      enable = true;
      config = { theme = "gruvbox-dark"; };
    };
    emacs = {
      enable = true;
      extraPackages = epkgs: [ epkgs.vterm ];
    };
    feh.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
    fzf = rec {
      enable = true;
      enableFishIntegration = false;
      changeDirWidgetCommand = "fd -H --type directory";
      defaultCommand = "fd -H -E '.git' --type file";
      fileWidgetCommand = defaultCommand;
    };
    git = {
      enable = true;
      package = pkgs.gitSVN;
      delta = {
        enable = true;
        options.syntax-theme = "gruvbox";
      };
      ignores = [
        "$RECYCLE.BIN/"
        "*.cab"
        "*.elc"
        "*.lnk"
        "*.msi"
        "*.msix"
        "*.msm"
        "*.msp"
        "*.rel"
        "*.stackdump"
        "*.tmp"
        "*.xlk"
        "*.~vsd*"
        "*_archive"
        "*_flymake.*"
        "*~"
        ".#*"
        ".Trash-*"
        ".cask/"
        ".dir-locals.el"
        ".directory"
        ".fuse_hidden*"
        ".netrwhist"
        ".nfs*"
        ".org-id-locations"
        ".projectile"
        ".~lock.*#"
        "/.emacs.desktop"
        "/.emacs.desktop.lock"
        "/auto/"
        "/elpa/"
        "/eshell/history"
        "/eshell/lastdir"
        "/network-security.data"
        "/server/"
        "Backup of *.doc*"
        "Session.vim"
        "Sessionx.vim"
        "Thumbs.db"
        "Thumbs.db:encryptable"
        "[._]*.s[a-v][a-z]"
        "[._]*.sw[a-p]"
        "[._]*.un~"
        "[._]s[a-rt-v][a-z]"
        "[._]ss[a-gi-z]"
        "[._]sw[a-p]"
        "[Dd]esktop.ini"
        "auto-save-list"
        "dist/"
        "ehthumbs.db"
        "ehthumbs_vista.db"
        "flycheck_*.el"
        "secring.*"
        "tags"
        "tramp"
        "~$*.doc*"
        "~$*.ppt*"
        "~$*.xls*"
      ];
      lfs.enable = true;
      signing = {
        key = "BA3A5886AE6D526E20B457D66A37DF9483188492";
        signByDefault = true;
      };
      userEmail = "ch.gpg@themaw.xyz";
      userName = "lunik1";
      extraConfig = {
        push.default = "matching";
        diff.algorithm = "histogram";
        github.user = "lunik1";
        gitlab.user = "lunik1";
      };
    };
    gh = {
      enable = true;
      gitProtocol = "ssh";
    };
    gpg.enable = true;
    kitty = {
      enable = true;
      font = {
        name = "Myosevka";
        package = myosevka;
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
    };
    mpv = {
      enable = true;
      # TODO: scripts
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
    ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    };
    ssh = import config/ssh/config.nix;
    texlive = {
      enable = true;
      extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
    };
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
    waybar = {
      enable = true;
      package = pkgs.waybar.override { pulseSupport = true; };
      settings = [{
        layer = "bottom";
        position = "bottom";
        # output = [ "eDP-1" ];
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" "idle_inhibitor" "mpd" ];
        modules-right = [
          "pulseaudio"
          "backlight"
          "memory"
          "cpu"
          "temperature"
          "disk"
          "network"
          "bluetooth"
          "battery"
          "clock"
          # "tray"
        ];
        modules = {
          "sway/workspaces".numeric-first = true;
          mpd = {
            format =
              "{stateIcon}{repeatIcon}{randomIcon}{singleIcon}{consumeIcon} {title} – {artist}";
            format-stopped = "";
            format-disconnected = "";
            interval = 5;
            max-length = 40;
            state-icons = {
              playing = "󰐊";
              paused = "󰏤";
            };
            consume-icons = {
              on = "󰮯";
              off = "";
            };
            random-icons = {
              on = "󰒟";
              off = "";
            };
            repeat-icons = {
              on = "󰑖";
              off = "";
            };
            single-icons = {
              on = "󰎤";
              off = "";
            };
          };
          pulseaudio = {
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-right =
              "${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
            format-icons = {
              # TODO bluetooth + muted icons? (needs support upstream?)
              car = "󰄋";
              hands-free = "󰋎";
              hdmi = "󰡁";
              headphone = "󰋋";
              headset = "󰋎";
              hifi = "󰗜";
              phone = "󰏶";
              portable = "󰏶";
              default = [ "󰕿" "󰖀" "󰕾" ];
            };
            format = "{icon}{volume}%";
            format-bluetooth = "{icon}󰂯{volume:3}%";
            format-muted = "󰝟 {volume}%";
          };
          backlight = {
            format = "{icon}{percent:3}%";
            format-icons = [ "󰌵" "󱉕" "󱉓" ];
            on-scroll-up = "${pkgs.light}/bin/light -A 1";
            on-scroll-down = "${pkgs.light}/bin/light -U 1";
            on-click-right = "${pkgs.light}/bin/light -S 100";
            on-click-middle = "${pkgs.light}/bin/light -S 0";
          };
          memory = {
            format = "󰩾 {used:0.2f}GiB";
            interval = 5;
          };
          cpu = {
            # TODO When 0.9.6 is released use format-state
            # https://github.com/Alexays/Waybar/pull/881
            format = "󰊚{usage:3}%";
            interval = 1;
          };
          temperature = {
            format = "󰔏{temperatureC}°C";
            format-critical = "󰸁 {temperatureC}°C";
            interval = 1;
            critical_threshold = 90;
            hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
          };
          disk = {
            format = "󰋊{percentage_used:3}%";
            interval = 60;
          };
          network = {
            format-wifi = "{icon}";
            interval = 20;
            format-ethernet = "󰈀";
            format-linked = "󰌷";
            format-icons = [ "󰤫" "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
            format-disconnected = "󰤮";
            on-click = "${pkgs.connman-gtk}/bin/connman-gtk";
            tooltip-format =
              "󰩟{ipaddr} 󰀂{essid} {frequency} {icon}{signalStrength} 󰕒{bandwidthUpBits} 󰇚{bandwidthDownBits}";
          };
          bluetooth = {
            format-icons = {
              disabled = "󰂲";
              enabled = "󰂯";
            };
            on-click = "${pkgs.blueman}/bin/blueman-manager";
            # TODO rfkill to disable/enable on right click
          };
          battery = {
            format = "{icon}";
            rotate = 270;
            # TODO set different icons when charging (currently broken?)
            format-icons = [ "󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            states = {
              critical = 10;
              warning = 30;
            };
            # TODO % capacity in tooltip
          };
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "󰅶";
              deactivated = "󰾪";
            };
          };
          clock = {
            interval = 1;
            format = "󰅐 {:%T}";
            tooltip-format = "{:%F}";
          };
        };
      }];
      # TODO use gruvbox colours
      style = (builtins.readFile (builtins.toPath
        "${config.programs.waybar.package}/etc/xdg/waybar/style.css")) + ''
          * {
            font-family: Myosevka;
            font-size: 20px;
          }

          #disk,
          #bluetooth {
            padding: 0 10px;
            margin: 0 4px;
          }

          #disk
          {
            background-color: #7c6f64
          }

          #bluetooth {
            background-color: #2980b9
          }

          #mpd.stopped {
            background: rgba(0, 0, 0, 0)
          }

          #mpd.disconnected {
            background: rgba(0, 0, 0, 0)
          }'';
    };
    zathura.enable = true;
  };

  pam.sessionVariables = { EDITOR = "nvim"; };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  services = {
    # TODO:
    # emacs.enable = true;
    # gnome-keyring
    # kanshi
    # random-background
    # udiskie
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };
    mpd = {
      enable = true;
      network.startWhenNeeded = true;
      extraConfig = ''
        audio_output {
          type            "pulse"
          name            "pulse audio"
        }

        audio_output {
          type            "fifo"
          name            "my_fifo"
          path            "/tmp/mpd.fifo"
          format          "44100:16:2"
        }'';
    };
    mpdris2.enable = true; # TODO: use mpd-mpris instead?
    playerctld.enable = true;
    syncthing = {
      enable = true;
      tray = false; # does not work on wayland
    };
  };

  systemd.user = {
    startServices = "sd-switch";
    services = {
      mega-cmd-server = {
        Unit = {
          Description = "MEGAcmd server";
          After = "network.target";
        };
        Install.WantedBy = [ "default.target" ];
        Service = {
          Environment = [ "HOME=${config.home.homeDirectory}" ];
          ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
          Restart = "on-failure";
          PrivateTmp = true;
          ProtectSystem = "full";
          Nice = 10;
          IOSchedulingClass = "best-effort";
          IOSchedulingPriority = 5;
        };
      };
    };
  };

  # TODO expand
  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    font = {
      package = myosevka-aile;
      name = "Myosevka Aile 11";
    };
    iconTheme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
    theme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
    gtk2.extraConfig = ''
      gtk-error-bell = 0
    '';
    gtk3.extraConfig.gtk-error-bell = 0;
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "opera.desktop" ];
        "text/xhtml_xml" = [ "opera.desktop" ];
        "application/x-opera-download" = [ "opera.desktop" ];
        "x-scheme-handler/about" = [ "opera.desktop" ];
        "x-scheme-handler/http" = [ "opera.desktop" ];
        "x-scheme-handler/https" = [ "opera.desktop" ];
        "x-scheme-handler/unknown" = [ "opera.desktop" ];

        "x-scheme-handler/msteams" = [ "teams.desktop" ];

        "x-scheme-handler/skype" = [ "skypeforlinux.desktop" ];

        "inode/directory" = [ "thunar.desktop" ];

        "message/rfc822" = [ "thunderbird.desktop" ];
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "x-scheme-handler/news" = [ "thunderbird.desktop" ];
        "x-scheme-handler/nntp" = [ "thunderbird.desktop" ];
        "x-scheme-handler/snews" = [ "thunderbird.desktop" ];

        "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
        "appliction/oxps" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
        "application/x-fictionbook" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
        "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
        "application/x-cbr" = [ "org.pwmt.zathura-cb.desktop" ];
        "application/x-cb7" = [ "org.pwmt.zathura-cb.desktop" ];
        "application/x-cbt" = [ "org.pwmt.zathura-cb.desktop" ];
        "image/vnd.djvu" = [ "org.pwmt.zathura-djvu.desktop" ];
        "image/vnd.djvu+multipage" = [ "org.pwmt.zathura-djvu.desktop" ];
        "application/postscript" = [ "org.pwmt.zathura-ps.desktop" ];
        "application/eps" = [ "org.pwmt.zathura-ps.desktop" ];
        "application/x-eps" = [ "org.pwmt.zathura-ps.desktop" ];
        "image/eps" = [ "org.pwmt.zathura-ps.desktop" ];
        "image/x-eps" = [ "org.pwmt.zathura-ps.desktop" ];

        "application/ogg" = [ "mpv.desktop" ];
        "application/x-ogg" = [ "mpv.desktop" ];
        "application/mxf" = [ "mpv.desktop" ];
        "application/sdp" = [ "mpv.desktop" ];
        "application/smil" = [ "mpv.desktop" ];
        "application/x-smil" = [ "mpv.desktop" ];
        "application/streamingmedia" = [ "mpv.desktop" ];
        "application/x-streamingmedia" = [ "mpv.desktop" ];
        "application/vnd.rn-realmedia" = [ "mpv.desktop" ];
        "application/vnd.rn-realmedia-vbr" = [ "mpv.desktop" ];
        "audio/aac" = [ "mpv.desktop" ];
        "audio/x-aac" = [ "mpv.desktop" ];
        "audio/vnd.dolby.heaac.1" = [ "mpv.desktop" ];
        "audio/vnd.dolby.heaac.2" = [ "mpv.desktop" ];
        "audio/aiff" = [ "mpv.desktop" ];
        "audio/x-aiff" = [ "mpv.desktop" ];
        "audio/m4a" = [ "mpv.desktop" ];
        "audio/x-m4a" = [ "mpv.desktop" ];
        "application/x-extension-m4a" = [ "mpv.desktop" ];
        "audio/mp1" = [ "mpv.desktop" ];
        "audio/x-mp1" = [ "mpv.desktop" ];
        "audio/mp2" = [ "mpv.desktop" ];
        "audio/x-mp2" = [ "mpv.desktop" ];
        "audio/mp3" = [ "mpv.desktop" ];
        "audio/x-mp3" = [ "mpv.desktop" ];
        "audio/mpeg" = [ "mpv.desktop" ];
        "audio/mpeg2" = [ "mpv.desktop" ];
        "audio/mpeg3" = [ "mpv.desktop" ];
        "audio/mpegurl" = [ "mpv.desktop" ];
        "audio/x-mpegurl" = [ "mpv.desktop" ];
        "audio/mpg" = [ "mpv.desktop" ];
        "audio/x-mpg" = [ "mpv.desktop" ];
        "audio/rn-mpeg" = [ "mpv.desktop" ];
        "audio/musepack" = [ "mpv.desktop" ];
        "audio/x-musepack" = [ "mpv.desktop" ];
        "audio/ogg" = [ "mpv.desktop" ];
        "audio/scpls" = [ "mpv.desktop" ];
        "audio/x-scpls" = [ "mpv.desktop" ];
        "audio/vnd.rn-realaudio" = [ "mpv.desktop" ];
        "audio/wav" = [ "mpv.desktop" ];
        "audio/x-pn-wav" = [ "mpv.desktop" ];
        "audio/x-pn-windows-pcm" = [ "mpv.desktop" ];
        "audio/x-realaudio" = [ "mpv.desktop" ];
        "audio/x-pn-realaudio" = [ "mpv.desktop" ];
        "audio/x-ms-wma" = [ "mpv.desktop" ];
        "audio/x-pls" = [ "mpv.desktop" ];
        "audio/x-wav" = [ "mpv.desktop" ];
        "video/mpeg" = [ "mpv.desktop" ];
        "video/x-mpeg2" = [ "mpv.desktop" ];
        "video/x-mpeg3" = [ "mpv.desktop" ];
        "video/mp4v-es" = [ "mpv.desktop" ];
        "video/x-m4v" = [ "mpv.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "application/x-extension-mp4" = [ "mpv.desktop" ];
        "video/divx" = [ "mpv.desktop" ];
        "video/vnd.divx" = [ "mpv.desktop" ];
        "video/msvideo" = [ "mpv.desktop" ];
        "video/x-msvideo" = [ "mpv.desktop" ];
        "video/ogg" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];
        "video/vnd.rn-realvideo" = [ "mpv.desktop" ];
        "video/x-ms-afs" = [ "mpv.desktop" ];
        "video/x-ms-asf" = [ "mpv.desktop" ];
        "audio/x-ms-asf" = [ "mpv.desktop" ];
        "application/vnd.ms-asf" = [ "mpv.desktop" ];
        "video/x-ms-wmv" = [ "mpv.desktop" ];
        "video/x-ms-wmx" = [ "mpv.desktop" ];
        "video/x-ms-wvxvideo" = [ "mpv.desktop" ];
        "video/x-avi" = [ "mpv.desktop" ];
        "video/avi" = [ "mpv.desktop" ];
        "video/x-flic" = [ "mpv.desktop" ];
        "video/fli" = [ "mpv.desktop" ];
        "video/x-flc" = [ "mpv.desktop" ];
        "video/flv" = [ "mpv.desktop" ];
        "video/x-flv" = [ "mpv.desktop" ];
        "video/x-theora" = [ "mpv.desktop" ];
        "video/x-theora+ogg" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/mkv" = [ "mpv.desktop" ];
        "audio/x-matroska" = [ "mpv.desktop" ];
        "application/x-matroska" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "audio/webm" = [ "mpv.desktop" ];
        "audio/vorbis" = [ "mpv.desktop" ];
        "audio/x-vorbis" = [ "mpv.desktop" ];
        "audio/x-vorbis+ogg" = [ "mpv.desktop" ];
        "video/x-ogm" = [ "mpv.desktop" ];
        "video/x-ogm+ogg" = [ "mpv.desktop" ];
        "application/x-ogm" = [ "mpv.desktop" ];
        "application/x-ogm-audio" = [ "mpv.desktop" ];
        "application/x-ogm-video" = [ "mpv.desktop" ];
        "application/x-shorten" = [ "mpv.desktop" ];
        "audio/x-shorten" = [ "mpv.desktop" ];
        "audio/x-ape" = [ "mpv.desktop" ];
        "audio/x-wavpack" = [ "mpv.desktop" ];
        "audio/x-tta" = [ "mpv.desktop" ];
        "audio/AMR" = [ "mpv.desktop" ];
        "audio/ac3" = [ "mpv.desktop" ];
        "audio/eac3" = [ "mpv.desktop" ];
        "audio/amr-wb" = [ "mpv.desktop" ];
        "video/mp2t" = [ "mpv.desktop" ];
        "audio/flac" = [ "mpv.desktop" ];
        "audio/mp4" = [ "mpv.desktop" ];
        "application/x-mpegurl" = [ "mpv.desktop" ];
        "video/vnd.mpegurl" = [ "mpv.desktop" ];
        "application/vnd.apple.mpegurl" = [ "mpv.desktop" ];
        "audio/x-pn-au" = [ "mpv.desktop" ];
        "video/3gp" = [ "mpv.desktop" ];
        "video/3gpp" = [ "mpv.desktop" ];
        "video/3gpp2" = [ "mpv.desktop" ];
        "audio/3gpp" = [ "mpv.desktop" ];
        "audio/3gpp2" = [ "mpv.desktop" ];
        "video/dv" = [ "mpv.desktop" ];
        "audio/dv" = [ "mpv.desktop" ];
        "audio/opus" = [ "mpv.desktop" ];
        "audio/vnd.dts" = [ "mpv.desktop" ];
        "audio/vnd.dts.hd" = [ "mpv.desktop" ];
        "audio/x-adpcm" = [ "mpv.desktop" ];
        "application/x-cue" = [ "mpv.desktop" ];
        "audio/m3u" = [ "mpv.desktop" ];

        # Libreoffice
        "application/vnd.openofficeorg.extension" = [ "startcenter.desktop" ];
        "x-scheme-handler/vnd.libreoffice.cmis" = [ "startcenter.desktop" ];

        "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet-template" =
          [ "calc.desktop" ];
        "application/vnd.sun.xml.calc" = [ "calc.desktop" ];
        "application/vnd.sun.xml.calc.template" = [ "calc.desktop" ];
        "application/msexcel" = [ "calc.desktop" ];
        "application/vnd.ms-excel" = [ "calc.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
          [ "calc.desktop" ];
        "application/vnd.ms-excel.sheet.macroEnabled.12" = [ "calc.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.template" =
          [ "calc.desktop" ];
        "application/vnd.ms-excel.template.macroEnabled.12" =
          [ "calc.desktop" ];
        "application/vnd.ms-excel.sheet.binary.macroEnabled.12" =
          [ "calc.desktop" ];
        "text/csv" = [ "calc.desktop" ];
        "application/x-dbf" = [ "calc.desktop" ];
        "text/spreadsheet" = [ "calc.desktop" ];
        "application/csv" = [ "calc.desktop" ];
        "application/excel" = [ "calc.desktop" ];
        "application/tab-separated-values" = [ "calc.desktop" ];
        "application/vnd.lotus-1-2-3" = [ "calc.desktop" ];
        "application/vnd.oasis.opendocument.chart" = [ "calc.desktop" ];
        "application/vnd.oasis.opendocument.chart-template" =
          [ "calc.desktop" ];
        "application/x-dbase" = [ "calc.desktop" ];
        "application/x-dos_ms_excel" = [ "calc.desktop" ];
        "application/x-excel" = [ "calc.desktop" ];
        "application/x-msexcel" = [ "calc.desktop" ];
        "application/x-ms-excel" = [ "calc.desktop" ];
        "application/x-quattropro" = [ "calc.desktop" ];
        "application/x-123" = [ "calc.desktop" ];
        "text/comma-separated-values" = [ "calc.desktop" ];
        "text/tab-separated-values" = [ "calc.desktop" ];
        "text/x-comma-separated-values" = [ "calc.desktop" ];
        "text/x-csv" = [ "calc.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet-flat-xml" =
          [ "calc.desktop" ];
        "application/x-iwork-numbers-sffnumbers" = [ "calc.desktop" ];
        "application/x-starcalc" = [ "calc.desktop" ];

        "application/vnd.oasis.opendocument.presentation" =
          [ "impress.desktop" ];
        "application/vnd.oasis.opendocument.presentation-template" =
          [ "impress.desktop" ];
        "application/vnd.sun.xml.impress" = [ "impress.desktop" ];
        "application/vnd.sun.xml.impress.template" = [ "impress.desktop" ];
        "application/mspowerpoint" = [ "impress.desktop" ];
        "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
          [ "impress.desktop" ];
        "application/vnd.ms-powerpoint.presentation.macroEnabled.12" =
          [ "impress.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.template" =
          [ "impress.desktop" ];
        "application/vnd.ms-powerpoint.template.macroEnabled.12" =
          [ "impress.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.slide" =
          [ "impress.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
          [ "impress.desktop" ];
        "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" =
          [ "impress.desktop" ];
        "application/vnd.oasis.opendocument.presentation-flat-xml" =
          [ "impress.desktop" ];
        "application/x-iwork-keynote-sffkey" = [ "impress.desktop" ];

        "application/vnd.oasis.opendocument.formula" = [ "math.desktop" ];
        "application/vnd.sun.xml.math" = [ "math.desktop" ];
        "application/vnd.oasis.opendocument.formula-template" =
          [ "math.desktop" ];
        "text/mathml" = [ "math.desktop" ];
        "application/mathml+xml" = [ "math.desktop" ];

        "application/vnd.oasis.opendocument.graphics" = [ "draw.desktop" ];
        "application/vnd.oasis.opendocument.graphics-flat-xml" =
          [ "draw.desktop" ];
        "application/vnd.oasis.opendocument.graphics-template" =
          [ "draw.desktop" ];
        "application/vnd.sun.xml.draw" = [ "draw.desktop" ];
        "application/vnd.sun.xml.draw.template" = [ "draw.desktop" ];
        "application/vnd.visio" = [ "draw.desktop" ];
        "application/x-wpg" = [ "draw.desktop" ];
        "application/vnd.corel-draw" = [ "draw.desktop" ];
        "application/vnd.ms-publisher" = [ "draw.desktop" ];
        "image/x-freehand" = [ "draw.desktop" ];
        "application/x-pagemaker" = [ "draw.desktop" ];
        "application/x-stardraw" = [ "draw.desktop" ];
        "image/x-emf" = [ "draw.desktop" ];
        "image/x-wmf" = [ "draw.desktop" ];

        "application/vnd.oasis.opendocument.database" = [ "base.desktop" ];
        "application/vnd.sun.xml.base" = [ "base.desktop" ];

        "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.text-template" =
          [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.text-web" = [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.text-master" = [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.text-master-template" =
          [ "writer.desktop" ];
        "application/vnd.sun.xml.writer" = [ "writer.desktop" ];
        "application/vnd.sun.xml.writer.template" = [ "writer.desktop" ];
        "application/vnd.sun.xml.writer.global" = [ "writer.desktop" ];
        "application/msword" = [ "writer.desktop" ];
        "application/vnd.ms-word" = [ "writer.desktop" ];
        "application/x-doc" = [ "writer.desktop" ];
        "application/x-hwp" = [ "writer.desktop" ];
        "application/rtf" = [ "writer.desktop" ];
        "text/rtf" = [ "writer.desktop" ];
        "application/vnd.wordperfect" = [ "writer.desktop" ];
        "application/wordperfect" = [ "writer.desktop" ];
        "application/vnd.lotus-wordpro" = [ "writer.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          [ "writer.desktop" ];
        "application/vnd.ms-word.document.macroEnabled.12" =
          [ "writer.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.template" =
          [ "writer.desktop" ];
        "application/vnd.ms-word.template.macroEnabled.12" =
          [ "writer.desktop" ];
        "application/vnd.ms-works" = [ "writer.desktop" ];
        "application/vnd.stardivision.writer-global" = [ "writer.desktop" ];
        "application/x-extension-txt" = [ "writer.desktop" ];
        "application/x-t602" = [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.text-flat-xml" =
          [ "writer.desktop" ];
        "application/x-fictionbook+xml" = [ "writer.desktop" ];
        "application/macwriteii" = [ "writer.desktop" ];
        "application/x-aportisdoc" = [ "writer.desktop" ];
        "application/prs.plucker" = [ "writer.desktop" ];
        "application/vnd.palm" = [ "writer.desktop" ];
        "application/clarisworks" = [ "writer.desktop" ];
        "application/x-sony-bbeb" = [ "writer.desktop" ];
        "application/x-abiword" = [ "writer.desktop" ];
        "application/x-iwork-pages-sffpages" = [ "writer.desktop" ];
        "application/x-mswrite" = [ "writer.desktop" ];
        "application/x-starwriter" = [ "writer.desktop" ];
      };
    };
  };
}
