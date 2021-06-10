# Base config, common to all machines

{ config, lib, pkgs, ... }:

{
  boot = {
    cleanTmpDir = true;
    blacklistedKernelModules = [ "ax25" "iTCO_wdt" "netrom" "rose" ];
    kernel.sysctl = {
      "vm.mmap_min_addr" = 65536;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
    };
    kernelParams = [
      "nowatchdog"
      "page_poison=1"
      "slab_nomerge"
      "slub_debug=FZP"
      "vsyscall=none"
      "kernel.kptr_restrict=2"
      "kernel.kexec_load_disabled=1"
    ];
  };

  i18n = { defaultLocale = "en_GB.UTF-8"; };
  console = { keyMap = "uk"; };
  time.timeZone = "Europe/London";

  nix = {
    useSandbox = "relaxed";
    autoOptimiseStore = true;
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
      neovim = pkgs.neovim.override {
        vimAlias = true;
        viAlias = true;
      };
    };
  };

  environment = {
    variables = { EDITOR = "nvim"; };

    # For zsh completion
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      gitMinimal
      neovim

      foot # TODO: use foot.terminfo once #125397 is in stable
      htop
      libarchive
      kitty.terminfo
      ntfs3g
      psmisc
      wget
    ];
  };

  programs = {
    dconf.enable = true;
    zsh.enable = true;
    nano.syntaxHighlight = true;
    iftop.enable = true;
  };

  services = {
    earlyoom.enable = true;
    fstrim.enable = true;
    irqbalance.enable = true;

    journald.extraConfig = ''
      SystemMaxUse=1G
    '';
  };

  # Needed to make swaylock work in home-manager
  security.pam.services.swaylock = { };

  users.users.corin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" ];
    shell = pkgs.zsh;
    initialHashedPassword =
      "$6$bE72miJzM$j2sh4WuC1UG1cdo3kkOVzuNTQ0V1LGGBVwz3nBWKiXzlkCm1IbgHEoMVDChsO2ccTP7VUNFg4I.qYW7FfBNQw.";
  };
}
