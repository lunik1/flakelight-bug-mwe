{ config, lib, pkgs, ... }:

{
  require = [ ./git.nix ];

  home.packages = with pkgs; [
    fd
    glslang
    gnuplot
    graphviz
    ripgrep

    emacs-all-the-icons-fonts
    myosevka
    myosevka-aile
    myosevka-etoile
  ];

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  services.gpg-agent.extraConfig = ''
    allow-emacs-pinentry
    allow-loopback-pinentry
  '';
}
