{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
            require = import modules/module-list.nix;

            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
            home.stateVersion = "20.09";

            lunik1.waybar.batteryModule = true;

            lunik1.core.enable = true;
            lunik1.cli.enable = true;
            lunik1.gui.enable = true;

            lunik1.bluetooth.enable = true;
            lunik1.emacs.enable = true;
            lunik1.fonts.enable = true;
            lunik1.games.cli.enable = true;
            lunik1.git.enable = true;
            lunik1.gpg.enable = true;
            lunik1.megacmd.enable = true;
            lunik1.mpv.enable = true;
            lunik1.music.enable = true;
            lunik1.neovim.enable = true;
            lunik1.pulp-io.enable = true;
            lunik1.sway.enable = true;
            lunik1.syncthing.enable = true;

            lunik1.lang.c.enable = true;
            lunik1.lang.clojure.enable = true;
            lunik1.lang.data.enable = true;
            lunik1.lang.julia.enable = true;
            lunik1.lang.nix.enable = true;
            lunik1.lang.prose.enable = true;
            lunik1.lang.python.enable = true;
            lunik1.lang.rust.enable = true;
            lunik1.lang.sh.enable = true;
            lunik1.lang.tex.enable = true;
          };
        };
      };
      foureightynine = self.homeConfigurations.foureightynine.activationPackage;
    };
}
