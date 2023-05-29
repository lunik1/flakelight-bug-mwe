{ hmModules, pkgsForSystem }:

rec {
  pkgs = pkgsForSystem "x86_64-linux";

  modules = [{
    require = import ../modules/home/module-list.nix;

    home = {
      username = "corin";
      homeDirectory = "/home/corin";
      stateVersion = "21.11";
    };

    lunik1.home = {
      vpsAdminOs = true;

      core.enable = true;
      cli.enable = true;

      emacs.enable = true;
      git.enable = true;
      gpg.enable = true;
      neovim.enable = true;

      lang.nix.enable = true;
    };
  }] ++ hmModules;
}
