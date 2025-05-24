# Base config, common to all machines

{
  config,
  lib,
  pkgs,
  ...
}:

let
  sopsKeyFile = "/etc/ssh/sops_key";
in
{
  boot = {
    tmp.cleanOnBoot = true;
    enableContainers = false;
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
    initrd.systemd.enable = !config.boot.swraid.enable && !config.boot.isContainer;
    kernel.sysctl =
      {
        "vm.mmap_min_addr" = 65536;
        "vm.mmap_rnd_compat_bits" = 16;

        # https://www.phoronix.com/scan.php?page=news_item&px=Dmesg-Unrestricted-2019-So-Far
        "kernel.dmesg_restrict" = true;

        # https://wiki.archlinux.org/title/security
        "net.core.bpf_jit_harden" = 2;

        # https://wiki.archlinux.org/title/Sysctl

        # Try to make sure we never run up against the inotify user watches limit
        "fs.inotify.max_user_watches" = 524288;

        # see also nixos/modules/profiles/hardened.nix
      }
      // lib.optionalAttrs pkgs.stdenv.isx86_64 {
        "vm.mmap_rnd_bits" = 32;
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

      # Enable delay accounting
      "delayacct"
    ];
  };

  system.rebuild.enableNg = true;

  i18n = {
    defaultLocale = "en_GB.UTF-8";
  };
  console = {
    keyMap = "uk";
    font =
      lib.mkOverride 1499 # option defult prio is 1500
        "Lat2-Terminus16";
  };
  time.timeZone = "Europe/London";

  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      Defaults lecture = never
      Defaults insults
    '';
  };

  networking = {
    firewall.logRefusedConnections = false;
    useNetworkd = true;
  };

  nix = {
    # try to make the system a bit more responsive while nix is operating
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedPriority = 5;

    channel.enable = false;

    # automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      sandbox = "relaxed";
      auto-optimise-store = true;

      trusted-users = [
        "root"
        "@wheel"
      ];

      # cachix
      substituters = [
        "https://lunik1-nix-config.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "lunik1-nix-config.cachix.org-1:GqZJS5q4NsaZfo2CszuqbB1WrvdyZJqO7e+JqNjtd94="
      ];
    };
  };

  environment = {
    variables = {
      AWK_HASH = "fnv1a";
      EDITOR = "nvim";
      KOPIA_CHECK_FOR_UPDATES = "false";
      KOPIA_BYTES_STRING_BASE_2 = "true";
    };

    # For zsh completion
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      gitMinimal
      git-crypt
      iotop
      neovim

      cloud-utils
      foot.terminfo
      ghostty.terminfo
      libarchive
      kitty.terminfo
      kitty.kitten
      ntfs3g
      psmisc
      wget
    ];
  };

  programs = {
    zsh.enable = true;
    nano.syntaxHighlight = true;
    iftop.enable = true;
    ssh.hostKeyAlgorithms = [
      "ssh-ed25519"
      "rsa-sha2-512"
    ];
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;

    nscd.enableNsncd = true;

    journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=1G
    '';

    # generate a key for encrypting sops secrets
  };

  # Sops
  system = {
    activationScripts = {
      # Generate an ed25519 key for usage with age/sops
      genereate-sops-ed25519 = ''
        if [ ! -f ${sopsKeyFile} ]; then
          ${pkgs.coreutils}/bin/mkdir \
            -p \
            $(${pkgs.coreutils}/bin/dirname ${sopsKeyFile})
          ${pkgs.openssh}/bin/ssh-keygen \
            -t ed25519 \
            -f ${sopsKeyFile} \
            -C "sops-${config.networking.hostName}" \
            -N ""
        fi
      '';
    };
  };

  sops = {
    age.sshKeyPaths = [ sopsKeyFile ];
    defaultSopsFile = ../../secrets/host/all/secrets.yaml;
    secrets.corin_password.neededForUsers = true;
  };

  users.users.corin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.corin_password.path;
  };
}
