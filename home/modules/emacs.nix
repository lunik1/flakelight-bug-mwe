{ config, lib, pkgs, ... }:

let cfg = config.lunik1.emacs;
in {
  options.lunik1.emacs.enable = lib.mkEnableOption "emacs";

  config = lib.mkIf cfg.enable {
    lunik1.git.enable = true;

    home.packages = with pkgs; [
      fd
      glslang
      gnuplot
      graphviz
      ripgrep
      sqlite.bin

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
  };
}
