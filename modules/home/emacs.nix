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

    home = {
      packages = with pkgs;
        [ fd glslang gnuplot graphviz pandoc ripgrep sqlite.bin ]
        ++ optionals cfg.gui [
          emacs-all-the-icons-fonts
          myosevka
          myosevka-aile
          myosevka-etoile
          zip # for org odt export
          (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
        ];

      sessionVariables = {
        LSP_USE_PLISTS = "true";
      };
    };

    programs.emacs =
      let
        settings = {
          withNativeCompilation = true;
          withGTK3 = cfg.gui;
          withPgtk = cfg.gui;
        };
        emacs-package = with pkgs;
          if stdenv.isDarwin then emacs29-macport
          else emacs29.override settings;
      in
      {
        enable = true;
        package = emacs-package;
        extraPackages = epkgs:
          [ epkgs.vterm ];
      };

    services.gpg-agent.extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
