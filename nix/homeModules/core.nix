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
          curlHTTP3
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

      file = {
        ".alsoftrc" = {
          text = ''
            hrtf = true
          '';
          target = ".alsoftrc";
        };
      };
    };

    nix.package = pkgs.nix;

    systemd.user.startServices = "sd-switch";

    # needed for eddie (doesn't work in gui.nix?)
    nixpkgs.config.permittedInsecurePackages =
      [ ]
      ++ lib.optionals config.lunik1.home.gui.enable [
        "dotnet-runtime-6.0.36"
        "dotnet-runtime-7.0.20"
        "dotnet-runtime-wrapped-6.0.36"
        "dotnet-runtime-wrapped-7.0.20"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-7.0.410"
        "dotnet-sdk-wrapped-6.0.428"
        "dotnet-sdk-wrapped-7.0.410"

        # needed by feishin
        "electron-31.7.7"
      ];

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.age-key.txt";
      defaultSopsFile = ../../secrets/user/secrets.yaml;
    };
  };
}
