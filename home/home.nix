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
      borgbackup
      bpytop
      chezmoi
      cmake
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
      ncdu
      nodejs
      opera
      p7zip
      pandoc
      parallel
      parted
      pavucontrol
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
      jq
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
    texlive = {
      enable = true;
      extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
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
    # mpd + mdpis
    # waybar
    # random-background
    # syncthing
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
    # random-background.enable = true;
  };

  systemd.user = {
    startServices = "sd-switch";
    services = {
      cmst = {
        Unit = {
          Description = "Connman systray icon";
          PartOf = "graphical-session.target";
          After = "graphical-session-pre.target";
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Environment = "DISPLAY=:1";
          ExecStart = "${pkgs.cmst}/bin/cmst -m";
          Restart = "on-failure";
          PrivateTmp = true;
          ProtectSystem = "full";
        };
      };
      megasync = {
        Unit = {
          Description = "MEGA syncing service";
          PartOf = "graphical-session.target";
          After = "graphical-session-pre.target";
          Nice = 10;
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Environment = [ "HOME=${config.home.homeDirectory}" "DISPLAY=:1" ];
          ExecStart = "${pkgs.megasync}/bin/megasync";
          Type = "forking";
          Restart = "on-failure";
          PrivateTmp = true;
          ProtectSystem = "full";
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
