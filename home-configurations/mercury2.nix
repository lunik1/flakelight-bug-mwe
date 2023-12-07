{ hmModules, pkgsForHome }:

rec {
  pkgs = pkgsForHome "aarch64-linux";

  modules = [{
    require = import ../modules/home/module-list.nix;

    home = {
      username = "corin";
      homeDirectory = "/home/corin";
      stateVersion = "23.05";
    };

    lunik1.home = {
      vpsAdminOs = true;

      core.enable = true;
      cli.enable = true;

      git.enable = true;
      gpg.enable = true;
      neovim.enable = true;

      lang.nix.enable = true;
    };
  }] ++ hmModules;
}
