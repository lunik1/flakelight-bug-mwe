pkgsForSystem:

rec {
  pkgs = pkgsForSystem "x86_64-linux";
  modules = [{
    require = import ../modules/home/module-list.nix;

    home = {
      username = "corin";
      homeDirectory = "/home/corin";
      stateVersion = "20.09";
    };

    lunik1.home = {
      waybar.batteryModule = true;

      core.enable = true;
      cli.enable = true;
      gui.enable = true;

      bluetooth.enable = true;
      emacs.enable = true;
      fonts.enable = true;
      games.cli.enable = true;
      git.enable = true;
      gpg.enable = true;
      gtk.enable = true;
      megacmd.enable = true;
      mpv.enable = true;
      music.enable = true;
      neovim.enable = true;
      pulp-io.enable = true;
      sway.enable = true;
      syncthing.enable = true;

      lang = {
        c.enable = true;
        clojure.enable = true;
        data.enable = true;
        julia.enable = true;
        nix.enable = true;
        prose.enable = true;
        python.enable = true;
        rust.enable = true;
        sh.enable = true;
        tex.enable = true;
      };
    };
  }];
}
