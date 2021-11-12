# Base config, common to all machines

{ config, lib, pkgs, ... }:

{
  boot = {
    cleanTmpDir = true;
    blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
    ];
    kernel.sysctl = {
      "vm.mmap_min_addr" = 65536;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;

      # https://www.phoronix.com/scan.php?page=news_item&px=Dmesg-Unrestricted-2019-So-Far
      "kernel.dmesg_restrict" = true;

      # https://wiki.archlinux.org/title/security
      "net.core.bpf_jit_harden" = 2;

      # https://wiki.archlinux.org/title/Sysctl

      # Try to make sure we never run up against the inotify user watches limit
      "fs.inotify.max_user_watches" = 524288;

      # see also nixos/modules/profiles/hardened.nix
    };
    kernelParams = [
      # Improve security
      # https://tails.boum.org/contribute/design/kernel_hardening/
      "page_poison=1"
      "slab_nomerge"
      "slub_debug=FZP"
      "vsyscall=none"
      "kernel.kptr_restrict=2"
      "kernel.kexec_load_disabled=1"

      # https://lwn.net/Articles/794145/
      "page_alloc.shuffle=1"

      # Reboot after 20 sec if the kernel panics
      "panic=20"
    ];
  };

  i18n = { defaultLocale = "en_GB.UTF-8"; };
  console = {
    keyMap = "uk";
    font = lib.mkOverride 1499 # option defult prio is 1500
      "Lat2-Terminus16"; # might be overidden by hidpi module
  };
  time.timeZone = "Europe/London";

  nix = {
    useSandbox = "relaxed";
    autoOptimiseStore = true;

    # try to make the system a bit more responsive while nix is operating
    daemonNiceLevel = 5;
    daemonIONiceLevel = 3;

    # enable flakes
    package = pkgs.nixUnstable;
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
      git-crypt
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
    zsh.enable = true;
    nano.syntaxHighlight = true;
    iftop.enable = true;
    ssh.hostKeyAlgorithms = [ "ssh-ed25519" "rsa-sha2-512" ];
  };

  services = {
    earlyoom = {
      enable = true;
      freeMemThreshold = 2;
    };
    fstrim.enable = true;
    fwupd.enable = true;
    irqbalance.enable = true;

    journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=1G
    '';
  };

  users.users.corin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" ];
    shell = pkgs.zsh;
    initialHashedPassword =
      "$6$bE72miJzM$j2sh4WuC1UG1cdo3kkOVzuNTQ0V1LGGBVwz3nBWKiXzlkCm1IbgHEoMVDChsO2ccTP7VUNFg4I.qYW7FfBNQw.";
  };
}
