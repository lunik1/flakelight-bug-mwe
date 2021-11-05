# # CLI tools installed by default on NixOS

{ pkgs, config, lib, ... }:

let cfg = config.lunik1.home.core;
in {
  options.lunik1.home.core.enable = lib.mkEnableOption "core programs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Core utils (installed by default on NixOS)
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
      openssh
      netcat
      procps
      su
      time
      util-linux
      which
      xz
      zstd

      # prevent collision with nix-zsh-completions (even though it isn't
      # explicitly installed??)
      (lib.hiPrio nix_2_4)
    ];

    # Use an if else to make sure config.nix is lazily loaded
    # (mkIf will not work!)
    programs.ssh = if config.lunik1.home.gpgKeyInstalled then
      import ../config/ssh/config.nix
    else
      { };

    xdg = {
      enable = true;
      configFile."nix.conf" = {
        text = ''
          experimental-features = nix-command flakes
          sandbox = relaxed
          auto-optimise-store = true
        '';
        target = "nix/nix.conf";
      };
    };
  };
}
