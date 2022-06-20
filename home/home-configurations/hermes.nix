{ home-manager, overlays, ... }:

home-manager.lib.homeManagerConfiguration {
  system = "x86_64-linux";
  username = "corin";
  homeDirectory = "/home/corin";
  stateVersion = "21.11";

  configuration = { pkgs, ... }: {
    require = import ../modules/module-list.nix;

    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (pkg: true);
      };
      inherit overlays;
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
  };
}
