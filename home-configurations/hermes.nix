pkgsForSystem:

rec {
  system = "x86_64-linux";
  pkgs = pkgsForSystem system;
  username = "corin";
  homeDirectory = "/home/corin";
  stateVersion = "21.11";

  configuration = {
    require = import ../modules/home/module-list.nix;

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
  };
}
