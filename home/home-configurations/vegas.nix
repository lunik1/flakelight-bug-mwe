{ home-manager, overlays, ... }:

home-manager.lib.homeManagerConfiguration {
  system = "x86_64-linux";
  username = "corin";
  homeDirectory = "/home/corin";
  stateVersion = "21.11";
  configuration = { pkgs, ... }: {
    require = import ../modules/module-list.nix;

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = (pkg: true);
    nixpkgs.overlays = overlays;

    targets.genericLinux.enable = true;

    xdg = {
      enable = true;
      configFile."nix.conf" = {
        text = ''
          max-jobs = 32
          cores = 0
        '';
      };
    };

    ## Machine-specifc dir hashes
    programs.zsh.dirHashes = { win = "/mnt/c/Users/chmic"; };

    lunik1.home = {
      core.enable = true;
      cli.enable = true;

      emacs = {
        enable = true;
        gui = true;
      };
      fonts.enable = true;
      git.enable = true;
      gpg.enable = true;
      neovim.enable = true;
      wsl.enable = true;

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
