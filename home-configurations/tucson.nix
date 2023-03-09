pkgsForSystem:

rec {
  pkgs = pkgsForSystem "x86_64-linux";
  modules = [{
    require = import ../modules/home/module-list.nix;

    home = {
      username = "corin";
      homeDirectory = "/home/corin";
      stateVersion = "21.05";
      packages = with pkgs; [ vial openrgb ];
    };

    lunik1.home = {
      core.enable = true;
      cli.enable = true;
      gui.enable = true;

      bluetooth.enable = true;
      emacs.enable = true;
      fonts.enable = true;
      games.cli.enable = true;
      git.enable = true;
      gpg.enable = true;
      kde.enable = true;
      megasync.enable = true;
      mpv = {
        enable = true;
        profile = "placebo";
      };
      neovim.enable = true;
      pulp-io.enable = true;
      syncthing.enable = true;

      games = {
        emu.enable = true;
        minecraft.enable = true;
        steam.enable = true;
      };

      lang = {
        c.enable = true;
        data.enable = true;
        julia.enable = true;
        nix.enable = true;
        prose.enable = true;
        python.enable = true;
        sh.enable = true;
      };
    };
  }];
}
