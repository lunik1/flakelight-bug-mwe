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

    # Use ffmpeg build with nonfree components
    nixpkgs.overlays = [
      (self: super: {
        ffmpeg-full = super.ffmpeg-full.override {
          buildFfplay = false;
          withUnfree = true;
          # withLTO = true; # broken https://github.com/NixOS/nixpkgs/issues/139168
        };
      })
    ];

    ## Machine-specifc dir hashes
    programs.zsh.dirHashes = {
      appdata = "/opt/appdata";
      kopia = "/mnt/storage/backup/kopia";
      movies = "/mnt/storage/Movies";
      music = "/mnt/storage/Music";
      storage = "/mnt/storage";
      tv = "/mnt/storage/TV";
    };

    lunik1.home = {
      core.enable = true;
      cli.enable = true;

      emacs.enable = true;
      git.enable = true;
      gpg.enable = true;
      media-management.enable = true;
      neovim.enable = true;

      lang.nix.enable = true;
    };
  }] ++ hmModules;
}
