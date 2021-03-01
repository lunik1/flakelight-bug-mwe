{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  hardware.cpu.intel.updateMicrocode = true;

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplip ];
  };

  boot.loader.systemd-boot = {
    enable = true;
    memtest86.enable = true;
    editor = false;
    consoleMode = "max";
    configurationLimit = 100;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;
  boot.initrd.kernelModules = [ "i915" "z3fold" ];
  boot.blacklistedKernelModules = [ "ax25" "iTCO_wdt" "netrom" "rose" ];
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/6a10e5fa-0a63-49cf-9c88-f3fa3ff78a83";
      preLVM = true;
      allowDiscards = true;
    };
  };
  boot.tmpOnTmpfs = true; # breaks builds that need a lot of space
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.mmap_min_addr" = 65536;
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
  };
  boot.kernelParams = [
    "zswap.enabled=1"
    "nowatchdog"
    "page_poison=1"
    "slab_nomerge"
    "slub_debug=FZP"
    "vsyscall=none"
    "kernel.kptr_restrict=2"
    "kernel.kexec_load_disabled=1"
  ];
  boot.initrd.preDeviceCommands = ''
    printf lzo-rle > /sys/module/zswap/parameters/compressor
    printf z3fold > /sys/module/zswap/parameters/zpool
  '';

  networking.hostName = "foureightynine";

  services.connman.enable = true;
  services.connman.wifi.backend = "iwd";
  # wpa_supplicant workaround
  # https://github.com/NixOS/nixpkgs/issues/23196 (workaround below)
  # networking.wireless.networks = {
  #   X39TH39GH92T29TJOR3GFJ3W2 = {};
  # };

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 10";
      }
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 10";
      }
    ];
  };

  security.rngd.enable = true;

  # Select internationalisation properties.
  i18n = { defaultLocale = "en_GB.UTF-8"; };

  console = { keyMap = "uk"; };

  time.timeZone = "Europe/London";

  nix = {
    # allowedUsers = [ "root" ];
    useSandbox = "relaxed";

    # enable flakes
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {

    iosevka-fixed-extended = pkgs.iosevka.override {
      set = "fixed-extended";
      privateBuildPlan = {
        family = "Iosevka Fixed";
        design = [ "sp-fixed" "sans" "ss03" "v-l-italic" "v-brace-curly" ];
        italic = [ "v-k-cursive" ];
        widths = {
          extended = {
            shape = 576;
            menu = 7;
            css = "normal";
          };
        };
      };
    };

    # chromium = pkgs.chromium.override { useVaapi = true; };  # takes ages to build
    neovim = pkgs.neovim.override {
      vimAlias = true;
      viAlias = true;
    };
    youtube-dl = pkgs.youtube-dl.override { phantomjsSupport = true; };
    zathura = pkgs.zathura.override { useMupdf = false; };
  };

  environment.variables = {
    EDITOR = "nvim";
    LIBVA_DRIVER_NAME = "iHD";
    MOZ_WEBRENDER = "1";
  };

  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [
    # emacs with vterm
    ((emacsPackagesNgGen emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]))

    # TODO make sqlite3 available to emacs only
    sqlite.bin

    aria2
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    bat
    bitwarden
    borgbackup
    bpytop
    chezmoi
    cmake
    cmst
    discord
    fd
    feh
    firefox-wayland
    flashplayer
    fzf
    git
    git-lfs
    gitAndTools.delta
    gnome3.simple-scan
    gnupg
    hplip
    htop
    kitty
    libarchive
    libreoffice-fresh
    magic-wormhole
    megasync
    mpv-with-scripts
    ncdu
    neovim
    nix-zsh-completions
    nodejs
    ntfs3g
    opera
    parted
    pavucontrol
    plex-media-player
    powertop
    psmisc
    qdirstat
    ranger
    ripgrep
    ripgrep-all
    rsync
    skanlite
    skypeforlinux
    system-config-printer
    tealdeer
    texlive.combined.scheme-full
    thunderbird
    wget
    yarn
    youtube-dl
    zathura
    zsh-completions

    # Games
    crawl
    crawlTiles
    # dwarf-fortress-packages.dwarf-fortress-full
    # freeciv
    # freeciv_gtk
    # freeciv_qt qt5.qtwayland
    openrct2
    wesnoth

    # Dev
    # C/C++
    ccls
    clang
    clang-tools
    gcc

    # Nix
    nixFlakes
    nixfmt
    nixpkgs-fmt

    # Python
    pipenv
    python37Packages.python-language-server
    python37Packages.pyls-isort

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

  virtualisation.docker.enable = true;

  fonts.fonts = with pkgs; [
    emacs-all-the-icons-fonts
    sarasa-gothic

    font-awesome
    iosevka-fixed-extended
    # iosevka-sparkle
    montserrat
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    source-code-pro
    source-sans-pro
    source-serif-pro
    # julia-mono
  ];
  fonts.enableDefaultFonts = true;

  fonts.fontconfig.defaultFonts.monospace =
    [ "Iosevka Fixed Extended" "Sarasa Fixed CL" "Julia Mono" ];
  fonts.fontconfig.hinting.enable = false; # > 200dpi

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    promptInit = "";
  };

  programs.nano.syntaxHighlight = true;

  programs.iotop.enable = true;
  programs.iftop.enable = true;

  programs.ssh.startAgent = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
  };

  networking.firewall.enable = false;

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    daemon.config = {
      resample-method = "soxr-vhq";
      avoid-resampling = "yes";
    };
  };

  hardware.video.hidpi.enable = true;

  hardware.bluetooth.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  services.logind.lidSwitch = "hybrid-sleep";
  services.logind.lidSwitchExternalPower = "suspend";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "gb";
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.enso.enable = true;
  services.xserver.displayManager.lightdm.background =
    pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;

  # No scheduler for non-rotational disks
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;
  programs.sway.extraPackages = with pkgs; [
    grim
    lm_sensors
    swaylock
    swayidle
    xwayland
    dmenu-wayland
    j4-dmenu-desktop
    i3status-rust
    upower
  ];

  services = {
    blueman.enable = true;
    earlyoom.enable = true;
    fstrim.enable = true;
    irqbalance.enable = true;
    tlp.enable = true;
    printing.enable = true;
    printing.drivers = [ pkgs.hplip ];
  };

  users.users.corin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    initialHashedPassword =
      "$6$bE72miJzM$j2sh4WuC1UG1cdo3kkOVzuNTQ0V1LGGBVwz3nBWKiXzlkCm1IbgHEoMVDChsO2ccTP7VUNFg4I.qYW7FfBNQw.";
  };

  system.extraSystemBuilderCmds = ''
    cp -r ${./.} $out/nixcfg
  '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

