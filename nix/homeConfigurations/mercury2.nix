{
  system = "x86_64-linux";
  modules = [{
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
  }];
}
