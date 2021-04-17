{ config, lib, pkgs, ... }:

{
  require = [ ./git.nix lang/viml.nix ];

  home = {
    packages = with pkgs; [
      neovim
      # Needed for plugins
      ripgrep
      fd
      yarn
      nodejs
    ];

    sessionVariables.EDITOR = "nvim";
  };

  pam.sessionVariables.EDITOR = "nvim";

  xdg = {
    enable = true;
    configFile = {
      "init.vim" = {
        source = ../config/nvim/init.vim;
        target = "nvim/init.vim";
      };
      "tasks.ini" = {
        source = ../config/nvim/tasks.ini;
        target = "nvim/tasks.ini";
      };
      "coc-settings.json" = {
        source = ../config/nvim/coc-settings.json;
        target = "nvim/coc-settings.json";
      };
    };
  };
}
