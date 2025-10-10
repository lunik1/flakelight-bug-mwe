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
    home.packages = with pkgs; [
      nix-fast-build
      nix-prefetch
      nix-update
      # nixops_unstable # does not build, insecure
      nixos-shell
      nixpkgs-fmt
      nixpkgs-lint-community
      nixpkgs-review
      nixfmt-rfc-style
      nurl
      nil
      statix
    ];

    programs.nix-init.enable = true;
  };
}
