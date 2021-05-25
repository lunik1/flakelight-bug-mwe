{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ svg2tikz texlab ];

  programs = {
    texlive = {
      enable = true;
      extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
    };
  };
}
