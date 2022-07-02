pkgsForSystem:

rec {
  system = "x86_64-linux";
  pkgs = pkgsForSystem system;
  username = "corin";
  homeDirectory = "/home/corin";
  stateVersion = "21.11";

  configuration = {
    require = import ../modules/home/module-list.nix;

    # Use ffmpeg build with nonfree components
    nixpkgs.overlays = [
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
