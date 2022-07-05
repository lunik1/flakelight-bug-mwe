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

    programs.ssh = let
      isEncrypted = with pkgs;
        f:
        !lib.hasInfix "text" (lib.fileContents (runCommandNoCCLocal "is-encrypted" {
          buildInputs = [ file ];
          src = f;
        } "file $src > $out"));
      sshConfig = ../../config/ssh/config.nix;
    in if isEncrypted sshConfig then
      builtins.trace "Warning: ssh config is encrypted, not building" { }
    else
      import sshConfig;

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
