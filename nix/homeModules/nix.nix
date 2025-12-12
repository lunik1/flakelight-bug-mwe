{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.nix;
in
{
  options.lunik1.home.lang.nix.enable = lib.mkEnableOption "Nix";

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        nix-prefetch
        # nixops_unstable # does not build, insecure
        nixos-shell
        nixpkgs-fmt
        nixpkgs-lint-community
        nixfmt-rfc-style
        nurl
        nil
        statix
      ]
      ++ (with lixPackageSets.stable; [
        nix-fast-build
        nix-update
        nixpkgs-review
      ]);

    programs.nix-init.enable = true;
  };
}
