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
    daemon = mkEnableOption "emacs daemon";
  };

  config = mkIf cfg.enable (
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
      lunik1.home.git.enable = true;

      home = {
        packages = with pkgs;
          [ fd glslang gnuplot graphviz pandoc ripgrep sqlite.bin ]
          ++ optionals cfg.gui [
            emacs-all-the-icons-fonts
            emacs-lsp-booster
            zip # for org odt export
            (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

            lunik1-nur.myosevka.mono
            lunik1-nur.myosevka.aile
            lunik1-nur.myosevka.etoile
          ];

        sessionVariables = {
          LSP_USE_PLISTS = "true";
        };
      };

      programs.emacs = {
        enable = true;
        package = emacs-package;
        extraPackages = epkgs:
          [ epkgs.vterm ];
      };

      services = {
        gpg-agent.extraConfig = ''
          allow-emacs-pinentry
          allow-loopback-pinentry
        '';
        emacs = mkIf cfg.daemon {
          enable = true;
          client.enable = true;
          socketActivation.enable = true;
        };
      };
    }
  );
}
