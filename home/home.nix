{ pkgs, ... }:

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
      getent
      getconf
      gnugrep
      gnupatch
      gnused
      gnutar
      gzip
      xz
      less
      libcap
      nano
      # ncurses
      netcat
      mkpasswd
      procps
      su
      time
      util-linux
      which
      xfce.thunar
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
      cmst
      discord
      duf
      element-desktop
      ffmpeg-full
      fd
      gnome3.simple-scan
      hplip
      libarchive
      libreoffice-fresh
      lrzip
      kitty # TODO: move to programs and configure
      magic-wormhole
      megasync
      ncdu
      nodejs
      opera
      p7zip
      pavucontrol
      parted
      plex-media-player
      psmisc
      qdirstat
      ranger
      ripgrep
      ripgrep-all
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

      # Emacs
      sqlite.bin

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
      poetry
      python-language-server

      # Clojure
      joker
      leiningen

      # Misc
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs

      # Linters
      nixpkgs-fmt
      nodePackages.write-good
      proselint
      python37Packages.yamllint
      vale
      vim-vint
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
      extraPackages = epkgs: [ epkgs.vterm pkgs.sqlite.bin ];
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
    # emacs.enable = true;
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

  # TODO expand
  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    font = {
      package = null;
      name = "Iosevka Aile 14";
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
