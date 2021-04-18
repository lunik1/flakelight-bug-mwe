{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ nixfmt nixpkgs-fmt nix-linter nixpkgs-lint ];
}
