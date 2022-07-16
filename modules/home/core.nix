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
      nix
      openssh
      netcat
      procps
      su
      time
      util-linux
      which
      xz
      zstd
    ];

    programs.ssh = let
      isEncrypted = with pkgs;
        f:
        !lib.hasInfix "text" (lib.fileContents
          (runCommandNoCCLocal "is-encrypted" {
            buildInputs = [ file ];
            src = f;
          } "file $src > $out"));
      sshConfig = ../../config/ssh/config.nix;
    in if isEncrypted sshConfig then
      builtins.trace "Warning: ssh config is encrypted, not building" { }
    else
      import sshConfig;

    nix = {
      package = pkgs.nix;
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        sandbox = "relaxed";
        substituters =
          [ "https://cache.nixos.org" "https://lunik1-nix-config.cachix.org" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "lunik1-nix-config.cachix.org-1:GqZJS5q4NsaZfo2CszuqbB1WrvdyZJqO7e+JqNjtd94="
        ];
      };
    };
  };
}
