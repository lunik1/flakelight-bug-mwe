{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    font-awesome-ttf
    julia-mono
    material-design-icons
    montserrat
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    sarasa-gothic
    source-code-pro
    source-sans-pro
    source-serif-pro
    myosevka
    myosevka-aile
    myosevka-etoile
    myosevka-proportional
  ];

  fonts.fontconfig.enable = true;
}
