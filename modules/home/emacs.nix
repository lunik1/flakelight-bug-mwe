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
    nativeComp = mkOption {
      default = true;
      description = "Whether to enable nativecomp.";
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
        zip # for org odt export
      ];

    programs.emacs =
      let
        settings = {
          inherit (cfg) nativeComp;
          withX = false;
          withNS = false;
          withGTK2 = false;
          withGTK3 = cfg.gui;
          withPgtk = cfg.gui;
          withWebP = true;
        };
        emacs-package = pkgs.emacsLsp.override settings;
      in
      {
        enable = true;
        package = emacs-package;
        extraPackages = epkgs:
          [ epkgs.vterm ] ++ optionals cfg.gui [ epkgs.pdf-tools ];
      };

    services.gpg-agent.extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
