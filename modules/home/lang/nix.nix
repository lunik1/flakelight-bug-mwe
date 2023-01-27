{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.nix;
in {
  options.lunik1.home.lang.nix.enable = lib.mkEnableOption "Nix";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # nix-linter # does not build, broken
      nix-prefetch
      nix-prefetch-git
      nix-prefetch-github
      nix-tree
      nix-update
      nixfmt
      # nixops_unstable # does not build, insecure
      nixos-shell
      nixpkgs-fmt
      nixpkgs-lint
      nixpkgs-review
      nurl
      rnix-lsp
    ];
  };
}
