pkgsForSystem:

rec {
  pkgs = pkgsForSystem "x86_64-linux";
  modules = [{
    require = import ../modules/home/module-list.nix;

    home = {
      username = "corin";
      homeDirectory = "/home/corin";
      stateVersion = "21.11";
    };

    targets.genericLinux.enable = true;

    programs.zsh = {
      ## Machine-specifc dir hashes
      dirHashes = { win = "/mnt/c/Users/chmic"; };
      profileExtra = ''
        setxkbmap -option compose:ralt
      '';
    };

    nix.settings = {
      max-jobs = 16;
      cores = 8;
    };

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
        data.enable = true;
        julia.enable = true;
        nix.enable = true;
        prose.enable = true;
        python.enable = true;
        rust.enable = true;
        sh.enable = true;
      };
    };
  }];
}
