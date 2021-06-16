{ config, pkgs, lib, ... }:

with lib;

let cfg = config.lunik1.home.emacs;
in {
  options.lunik1.home.emacs = {
    enable = mkEnableOption "emacs";
    gui = mkOption {
      default = config.lunik1.home.gui.enable;
      description = "Whether to enable Emacs' gui.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    lunik1.home.git.enable = true;

    home.packages = with pkgs;
      [ fd glslang gnuplot graphviz pandoc ripgrep sqlite.bin ]
      ++ optionals cfg.gui [
        emacs-all-the-icons-fonts
        myosevka
        myosevka-aile
        myosevka-etoile
      ];

    programs.emacs = {
      enable = true;
      package = with pkgs; if cfg.gui then emacs else emacs-nox;
      extraPackages = epkgs:
        [ epkgs.vterm ] ++ optionals cfg.gui [ epkgs.pdf-tools ];
    };

    services.gpg-agent.extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
