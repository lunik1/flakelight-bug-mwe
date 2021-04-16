{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    LS_COLORS = {
      url = "github:trapd00r/LS_COLORS";
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }:
    let
      # nixos-unstable-overlay = final: prev: {
      #   nixos-unstable = import inputs.nixos-unstable {
      #     system = prev.system;
      #     # config.allowUnfree = true;
      #     overlays = [ inputs.emacs-overlay.overlay ];
      #   };
      # };
      overlays = [
        # nixos-unstable-overlay
        (self: super: {
          youtube-dl = super.youtube-dl.override { phantomjsSupport = true; };
          myosevka = super.iosevka.override {
            privateBuildPlan = import resources/iosevka/myosevka.nix;
            set = "myosevka";
          };
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
        (final: prev: { LS_COLORS = inputs.LS_COLORS; })
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

              modules/games.nix
            ];

            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
            home.stateVersion = "20.09";

            waybar.batteryModule = true;
            games.cli.enable = true;
          };
        };
      };
      foureightynine = self.homeConfigurations.foureightynine.activationPackage;
    };
}
