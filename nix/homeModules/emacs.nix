{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.lunik1.home.emacs;
in
{
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
      emacs-package = pkgs.emacs30-pgtk.overrideAttrs (
        new: old: { configureFlags = old.configureFlags ++ [ "--disable-gc-mark-trace" ]; }
      );
    in
    {
      lunik1.home.git.enable = true;

      home = {
        packages =
          with pkgs;
          [
            beancount-language-server
            dockerfile-language-server-nodejs
            fd
            glslang
            gnuplot
            graphviz
            lua-language-server
            lua54Packages.digestif
            markdownlint-cli2
            marksman
            nodePackages_latest.bash-language-server
            pandoc
            proselint
            ripgrep
            sqlite.bin
          ]
          ++ optionals cfg.gui [
            emacs-all-the-icons-fonts
            emacs-lsp-booster
            nerd-fonts.symbols-only
            zip # for org odt export

            lunik1-nur.myosevka.mono
            lunik1-nur.myosevka.aile
            lunik1-nur.myosevka.etoile
          ]
          ++ optionals config.lunik1.home.lang.clojure.enable [
            clojure-lsp
          ]
          ++ optionals config.lunik1.home.lang.data.enable [
            nodePackages_latest.vscode-json-languageserver
            taplo
            yaml-language-server
            yamllint
            yamlfmt
          ]
          ++ optionals config.lunik1.home.lang.nix.enable [
            nil
            statix
          ];

        sessionVariables = {
          LSP_USE_PLISTS = "true";
        };
      };

      programs.emacs = {
        enable = true;
        package = emacs-package;
        extraPackages = epkgs: [ epkgs.vterm ];
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
