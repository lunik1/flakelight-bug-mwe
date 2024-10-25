# # CLI tools installed by default on NixOS

{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.lunik1.home.core;
in
{
  options.lunik1.home.core.enable = lib.mkEnableOption "core programs";

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
          gnugrep
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

      sessionVariables.AWK_HASH = "fnv1a";
    };

    nix.package = pkgs.nix;

    systemd.user.startServices = "sd-switch";

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.age-key.txt";
      defaultSopsFile = ../../secrets/user/secrets.yaml;
    };
  };
}
