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

      nixFlakes
    ];

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
