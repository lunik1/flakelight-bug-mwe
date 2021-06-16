{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.neovim;
in {
  options.lunik1.home.neovim.enable = lib.mkEnableOption "Neovim";

  config = lib.mkIf cfg.enable {
    lunik1.home = {
      git.enable = true;
      lang.viml.enable = true;
    };

    home = {
      packages = with pkgs; [
        neovim
        # Needed for plugins
        ripgrep
        fd
        wl-clipboard
        xclip
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
  };
}
