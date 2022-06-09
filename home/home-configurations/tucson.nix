{ inputs, overlays, ... }:

inputs.home-manager.lib.homeManagerConfiguration {
  system = "x86_64-linux";
  username = "corin";
  homeDirectory = "/home/corin";
  stateVersion = "21.05";
  configuration = { pkgs, ... }: {
    require = import ../modules/module-list.nix;

    nixpkgs.config.allowUnfree = true;
    # https://github.com/nix-community/home-manager/issues/2942 workaround
    nixpkgs.config.allowUnfreePredicate = (pkg: true);
    nixpkgs.overlays = overlays;

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
  };
}
