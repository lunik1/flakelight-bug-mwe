# Home configuration for non-NixOS systems

{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.lunik1.home.non-nixos;
in
{
  options.lunik1.home.non-nixos.enable = lib.mkEnableOption "configuration for non-nixos systems";

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          # Core utils (installed by default on NixOS)
          bashInteractive
          bzip2
          cpio
          curl
          diffutils
          findutils
          gawk
          getconf
          getent
          gnupatch
          gnused
          gnutar
          gzip
          less
          mkpasswd
          nano
          nix
          openssh
          netcat
          time
          which
          xz
          zstd
        ]
        ++ lib.optionals stdenv.isLinux [
          acl
          coreutils-full
          libcap
          procps
          su
          util-linux
        ]
        ++ lib.optionals stdenv.isDarwin [ coreutils ];
    };

    services.home-manager.autoExpire = {
      enable = pkgs.stdenv.isLinux;
      frequency = "weekly";
      timestamp = "-14 days";
    };

    programs.grep.enable = true;

    nix.package = pkgs.lix;
  };
}
