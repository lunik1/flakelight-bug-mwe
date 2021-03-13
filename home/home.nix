{ pkgs, config, ... }:

{
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
      gnome3.simple-scan
      hplip
      imagemagick
      kitty # TODO: move to programs and configure
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
      wget
      yarn
      youtube-dl

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
    gpg.enable = true;
    # kitty = {
    #     enable = true;
    #     # TODO: config
    # };
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
    texlive = {
      enable = true;
      extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
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
          "tray"
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
              car = "󰄋";
              hands-free = "󰋎";
              hdmi = "󰡁";
              headphone = "󰋋";
              # headphone-muted = "󰟎";
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
            format = "{icon}{temperatureC}°C";
            format-critical = "󰸁  {temperatureC}°C";
            format-icons = [ "󱃃" "󰔏" "󱃂" ];
            interval = 1;
            critical_threshold = 90;
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
            font-family: monospace;
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
    blueman-applet.enable = true;
    # TODO:
    # caffeine.enable = true;  # TODO find alternative that works with sway
    # emacs.enable = true;
    # gnome-keyring
    # kanshi
    # waybar
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
      # megasync = {
      #   Unit = {
      #     Description = "MEGA syncing service";
      #     PartOf = "graphical-session.target";
      #     After = "graphical-session-pre.target";
      #     Nice = 10;
      #   };
      #   Install.WantedBy = [ "graphical-session.target" ];
      #   Service = {
      #     Environment = [ "HOME=${config.home.homeDirectory}" "DISPLAY=:1" ];
      #     ExecStart = "${pkgs.megasync}/bin/megasync";
      #     Restart = "on-failure";
      #     PrivateTmp = true;
      #     ProtectSystem = "full";
      #   };
      # };
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
      package = null;
      name = "Iosevka Aile 11";
    };
    iconTheme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
    theme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
  };

  home.stateVersion = "20.09";
}
