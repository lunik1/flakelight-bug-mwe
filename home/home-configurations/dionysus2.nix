{ home-manager, overlays, ... }:

home-manager.lib.homeManagerConfiguration {
  system = "x86_64-linux";
  username = "corin";
  homeDirectory = "/home/corin";
  stateVersion = "21.11";

  configuration = { pkgs, ... }: {
    require = import ../modules/home/module-list.nix;

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = (pkg: true);

    # Use ffmpeg build with nonfree components
    nixpkgs.overlays = overlays ++ [
      (self: super: {
        ffmpeg-full = super.ffmpeg-full.override {
          ffplayProgram = false;
          runtimeCpuDetectBuild = false; # compile natively
          nonfreeLicensing = true;
          # enableLto = true; # broken https://github.com/NixOS/nixpkgs/issues/139168
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
  };
}
