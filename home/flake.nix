{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-logo-gruvbox-wallpaper = {
      url = "github:lunik1/nixos-logo-gruvbox-wallpaper";
      flake = false;
    };
    LS_COLORS = {
      url = "github:trapd00r/LS_COLORS";
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }:
    let
      overlays = [
        (self: super: {
          youtube-dl = super.youtube-dl.override { phantomjsSupport = true; };
          myosevka = super.iosevka.override {
            privateBuildPlan = import resources/iosevka/myosevka.nix;
            set = "myosevka";
          };
        })
        (self: super: {
          myosevka-proportional = super.iosevka.override {
            privateBuildPlan =
              import resources/iosevka/myosevka-proportional.nix;
            set = "myosevka-proportional";
          };
          myosevka-aile = super.iosevka.override {
            privateBuildPlan =
              (import resources/iosevka/myosevka-aile.nix) { lib = super.lib; };
            set = "myosevka-aile";
          };
          myosevka-etoile = super.iosevka.override {
            privateBuildPlan = (import resources/iosevka/myosevka-etoile.nix) {
              lib = super.lib;
            };
            set = "myosevka-etoile";
          };
        })
        (self: super: { LS_COLORS = inputs.LS_COLORS; })
        (self: super: {
          nixos-logo-gruvbox-wallpaper = inputs.nixos-logo-gruvbox-wallpaper;
        })
      ];
    in {
      homeConfigurations = {
        foureightynine = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          username = "corin";
          homeDirectory = "/home/corin";
          configuration = { pkgs, ... }: {
            require = [
              modules/core.nix
              modules/cli.nix
              modules/gui.nix
              modules/git.nix
              modules/neovim.nix
              modules/emacs.nix
              modules/fonts.nix
              modules/music.nix
              modules/sync.nix
              modules/sway.nix
              modules/bluetooth.nix
              modules/mpv.nix
              modules/gpg.nix
              modules/pulp-io.nix
              modules/games.nix

              modules/lang/c.nix
              modules/lang/clojure.nix
              modules/lang/data.nix
              modules/lang/julia.nix
              modules/lang/nix.nix
              modules/lang/prose.nix
              modules/lang/python.nix
              modules/lang/rust.nix
              modules/lang/sh.nix
              modules/lang/tex.nix
            ];

            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
            home.stateVersion = "20.09";

            waybar.batteryModule = true;
            waybar.bluetoothModule =
              true; # TODO activate if bluetooth.nix included
            games.cli.enable = true;
          };
        };
      };
      foureightynine = self.homeConfigurations.foureightynine.activationPackage;
    };
}
