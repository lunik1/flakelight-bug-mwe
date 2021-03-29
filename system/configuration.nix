{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  ## Hardware
  hardware.cpu.intel.updateMicrocode = true;

  ## Boot & Kernel
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
        editor = false;
        consoleMode = "max";
        configurationLimit = 100;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      kernelModules = [ "i915" "z3fold" ];
      luks.devices = {
        root = {
          device = "/dev/disk/by-uuid/6a10e5fa-0a63-49cf-9c88-f3fa3ff78a83";
          preLVM = true;
          allowDiscards = true;
        };
      };
      preDeviceCommands = ''
        printf lzo-rle > /sys/module/zswap/parameters/compressor
        printf z3fold > /sys/module/zswap/parameters/zpool
      '';
    };
    cleanTmpDir = true;
    blacklistedKernelModules = [ "ax25" "iTCO_wdt" "netrom" "rose" ];
    # tmpOnTmpfs = false; # can break builds that need a lot of space
    kernelPackages = pkgs.linuxPackages_zen;
    kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.mmap_min_addr" = 65536;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
    };
    kernelParams = [
      "zswap.enabled=1"
      "nowatchdog"
      "page_poison=1"
      "slab_nomerge"
      "slub_debug=FZP"
      "vsyscall=none"
      "kernel.kptr_restrict=2"
      "kernel.kexec_load_disabled=1"

      # https://redd.it/ihdozd
      "intel_pstate=active"
    ];
  };

  ## Networking
  networking = {
    hostName = "foureightynine";
    firewall.enable = false;
  };
  services.connman = {
    enable = true;
    wifi.backend = "iwd";
  };

  ## Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  ## Backlight
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

  ## System
  # Select internationalisation properties.
  i18n = { defaultLocale = "en_GB.UTF-8"; };
  console = { keyMap = "uk"; };

  time.timeZone = "Europe/London";

  ## Security
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "/run/current-system/sw/bin/rfkill";
      options = [ "NOPASSWD" ];
    }];
  }];

  ## Nix
  nix = {
    useSandbox = "relaxed";
    # enable flakes
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  ## Nixpkgs
  nixpkgs.config = {
    allowUnfree = true;
    # Package overrides
    packageOverrides = pkgs: {
      # chromium = pkgs.chromium.override { useVaapi = true; };  # takes ages to build
      neovim = pkgs.neovim.override {
        vimAlias = true;
        viAlias = true;
      };
    };
  };

  ## Environment & Programs
  environment = {
    variables = {
      EDITOR = "nvim";
      GTK_IM_MODULE = "xim";
    };

    # For zsh completion
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      # TODO add these to home-manager
      git
      git-lfs
      gitAndTools.delta
      neovim
      nix-zsh-completions
      zsh-completions

      htop
      libarchive
      kitty.terminfo
      ntfs3g
      powertop
      psmisc
      wget
    ];
  };

  programs = {
    zsh.enable = true;
    nano.syntaxHighlight = true;
    iotop.enable = true;
    iftop.enable = true;
    ssh.startAgent = true;
    sway = {
      enable = true;

      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
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
    };
  };
  gtk.iconCache.enable = true;

  ## Fonts
  fonts = {
    fonts = with pkgs; [
      emacs-all-the-icons-fonts
      font-awesome-ttf
      material-design-icons
      montserrat
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      sarasa-gothic
      source-code-pro
      source-sans-pro
      source-serif-pro
      # TODO: iosevka
      # julia-mono
    ];
    enableDefaultFonts = true;
    fontconfig = {
      defaultFonts.monospace = [
        "Source Code Pro"
        "Sarasa Fixed CL"
        "Sarasa Fixed HC"
        "Sarasa Fixed TC"
        "Sarasa Fixed J"
        "Sarasa Fixed K"
        # "Julia Mono"
        "all-the-icons"
        "file-icons"
        "Material Icons"
        "Font Awesome 5 Free"
        "Font Awesome 5 Brands"
      ];
      defaultFonts.serif = [
        "Source Serif Pro"
        "all-the-icons"
        "file-icons"
        "Material Icons"
        "Font Awesome 5 Free"
        "Font Awesome 5 Brands"
      ];
      defaultFonts.sansSerif = [
        "Source Sans Pro"
        "all-the-icons"
        "file-icons"
        "Material Icons"
        "Font Awesome 5 Free"
        "Font Awesome 5 Brands"
      ];
      defaultFonts.emoji = [
        "Noto Color Emoji"
        "Material Icons"
        "Font Awesome 5 Free"
        "Font Awesome 5 Brands"
      ];
      hinting.enable = false; # > 200dpi
    };
  };

  ## Sound
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      daemon.config = {
        resample-method = "soxr-vhq";
        avoid-resampling = "yes";
      };
    };
  };

  ## Video
  hardware.video.hidpi.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true; # for steam
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  ## Services
  services = {
    logind.lidSwitch = "hybrid-sleep";
    logind.lidSwitchExternalPower = "suspend";

    # X11
    xserver = {
      enable = true;
      layout = "gb";
      libinput.enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.enso.enable = true;
        background =
          pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
      };
    };

    # No scheduler for non-rotational disks
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    '';

    earlyoom.enable = true;
    fstrim.enable = true;
    irqbalance.enable = true;
    tlp.enable = true;
  };

  ## Printing and Scanning
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplip ];
  };
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };
  ## Users
  users.users.corin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    initialHashedPassword =
      "$6$bE72miJzM$j2sh4WuC1UG1cdo3kkOVzuNTQ0V1LGGBVwz3nBWKiXzlkCm1IbgHEoMVDChsO2ccTP7VUNFg4I.qYW7FfBNQw.";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
