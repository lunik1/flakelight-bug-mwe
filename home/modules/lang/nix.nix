{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    nix-linter
    nix-prefetch
    nix-prefetch-git
    nix-prefetch-github
    nix-tree
    nixfmt
    nixpkgs-fmt
    nixpkgs-lint
  ];
}
