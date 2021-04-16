{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    languagetool
    nodePackages.write-good
    proselint
    vale
  ];
}
