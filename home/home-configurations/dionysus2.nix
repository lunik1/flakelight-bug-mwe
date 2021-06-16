{ config, lib, pkgs, ... }:

inputs.home-manager.lib.homeManagerConfiguration {
  system = "x86_64-linux";
  username = "corin";
  homeDirectory = "/home/corin";
  stateVersion = "18.03";

  configuration = { pkgs, ... }: {
    require = import ../modules/module-list.nix;

    nixpkgs.config.allowUnfree = true;

    # Use ffmprg build with nonfree components
    nixpkgs.overlays = overlays ++ [
      (self: super: {
        ffmpeg-full = pkgs.ffmpeg-full.override {
          ffplayProgram = false;
          runtimeCpuDetectBuild = false; # compile natively
          nonfreeLicensing = true;
          enableLto = true;
        };
      })
    ];

    lunik1.home = {
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
