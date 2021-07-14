{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.nix;
in {
  options.lunik1.home.lang.nix.enable = lib.mkEnableOption "Nix";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nix-linter
      nix-prefetch
      nix-prefetch-git
      nix-prefetch-github
      nix-tree
      nix-update
      nixfmt
      nixos-shell
      nixpkgs-fmt
      nixpkgs-lint
      rnix-lsp
    ];
  };
}
