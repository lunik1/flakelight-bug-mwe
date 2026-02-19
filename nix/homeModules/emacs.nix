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
      emacs-package =
        with pkgs;
        (if stdenv.isDarwin then emacs-macport else emacs30-pgtk).overrideAttrs (
          new: old: {
            env = (old.env or { }) // {
              NIX_CFLAGS_COMPILE =
                (old.env.NIX_CFLAGS_COMPILE or "")
                + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin " -DFD_SETSIZE=10000 -DDARWIN_UNLIMITED_SELECT";
            };
          }
        );
    in
    {
      lunik1.home.git.enable = true;

      home = {
        packages =
          with pkgs;
          [
            dockerfile-language-server
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
            symbola
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

      programs = {
        emacs = {
          enable = true;
          package = emacs-package;
          extraPackages = epkgs: [ epkgs.vterm ];
        };

        zsh.shellAliases = {
          doom = "~/.emacs.d/bin/doom";
          ec = "emacsclient -a '' -t";

          "dired" = ''emacsclient -a \'\' -t --eval "(dired \"$PWD\")"'';
          "dired+" = ''emacs -nw --eval "(dired \"$PWD\")"'';
          "dirvish" = "emacsclient -a '' -t --eval '(dirvish)'";
          "dirvish+" = "emacs -nw --eval '(dirvish)";
          "magit" = "emacsclient -a '' -t --eval '(magit)'";
          "magit+" = "emacs -nw --eval '(magit)'";
        };
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
