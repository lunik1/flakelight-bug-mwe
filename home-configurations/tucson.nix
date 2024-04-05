{ moduleArgs }:

{
  system = "x86_64-linux";
  modules = [
    ({ pkgs, ... }: {
      require = import ../modules/home/module-list.nix;

      home = {
        username = "corin";
        homeDirectory = "/home/corin";
        stateVersion = "21.05";
        packages = with pkgs; [ vial ];
      };

      # Secrets
      sops.secrets.cachix_auth_token = { };

      lunik1.home = {
        core.enable = true;
        cli.enable = true;
        gui.enable = true;

        bluetooth.enable = true;
        emacs.enable = true;
        fonts.enable = true;
        git.enable = true;
        gpg.enable = true;
        gnome.enable = true;
        megasync.enable = true;
        mpv = {
          enable = true;
          profile = "placebo";
        };
        music.enable = true;
        neovim.enable = true;
        pulp-io.enable = true;
        syncthing.enable = true;

        games = {
          emu.enable = true;
          minecraft.enable = true;
          steam.enable = true;
          osu.enable = true;
          saves.enable = true;
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
    })
  ];
}
