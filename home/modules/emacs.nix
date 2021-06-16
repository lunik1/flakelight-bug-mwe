{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.emacs;
in {
  options.lunik1.home.emacs.enable = lib.mkEnableOption "emacs";

  config = lib.mkIf cfg.enable {
    lunik1.home.git.enable = true;

    home.packages = with pkgs;
      [ fd glslang gnuplot graphviz pandoc ripgrep sqlite.bin ]
      ++ lib.optionals config.lunik1.home.gui.enable [
        emacs-all-the-icons-fonts
        myosevka
        myosevka-aile
        myosevka-etoile
      ];

    programs.emacs = {
      enable = true;
      package = with pkgs;
        if config.lunik1.home.gui.enable then emacs else emacs-nox;
      extraPackages = epkgs:
        [ epkgs.vterm ]
        ++ lib.optionals config.lunik1.home.gui.enable [ epkgs.pdf-tools ];
    };

    services.gpg-agent.extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
