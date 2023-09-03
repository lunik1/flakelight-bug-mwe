# # CLI tools installed by default on NixOS

{ pkgs, config, lib, ... }:

let cfg = config.lunik1.home.core;
in {
  options.lunik1.home.core.enable = lib.mkEnableOption "core programs";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
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
      ] ++ lib.optionals stdenv.isLinux [
        acl
        coreutils-full
        libcap
        procps
        su
        util-linux
      ] ++ lib.optionals stdenv.isDarwin [
        coreutils-prefixed
      ];

      sessionVariables.AWK_HASH = "fnv1a";
    };

    programs.ssh =
      let
        sshConfig = ../../config/ssh/config.nix;
      in
      if pkgs.lib.lunik1.isEncrypted sshConfig then
        builtins.trace "Warning: ssh config is encrypted, not building" { }
      else
        import sshConfig;

    nix = {
      package = pkgs.nix;
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        # Sandbox is a little bit broken on darwin
        # https://github.com/NixOS/nix/issues/4119
        sandbox = if pkgs.stdenv.isDarwin then false else "relaxed";
        substituters =
          [ "https://cache.nixos.org" "https://lunik1-nix-config.cachix.org" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "lunik1-nix-config.cachix.org-1:GqZJS5q4NsaZfo2CszuqbB1WrvdyZJqO7e+JqNjtd94="
        ];
      };
    };

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.age-key.txt";
      defaultSopsFile = ../../secrets/user/secrets.yaml;
    };
  };
}
