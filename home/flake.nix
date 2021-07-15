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
    firefox-lepton = {
      url = "github:black7375/Firefox-UI-Fix";
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }:
    let
      overlays = [
        (self: super: {
          youtube-dl = super.youtube-dl.override { phantomjsSupport = true; };
        })
        (self: super: {
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
        (self: super: { LS_COLORS = inputs.LS_COLORS; })
        (self: super: { firefox-lepton = inputs.firefox-lepton; })
        (self: super: {
          neovim = super.neovim.override {
            vimAlias = true;
            viAlias = true;
          };
        })
        (self: super: {
          nixos-logo-gruvbox-wallpaper = inputs.nixos-logo-gruvbox-wallpaper;
        })
      ];
    in {
      foureightynine = (import home-configurations/foureightynine.nix {
        inherit inputs;
        inherit overlays;
      }).activationPackage;
      thesus = (import home-configurations/thesus.nix {
        inherit inputs;
        inherit overlays;
      }).activationPackage;
      dionysus2 = (import home-configurations/dionysus2.nix {
        inherit inputs;
        inherit overlays;
      }).activationPackage;
      hermes = (import home-configurations/hermes.nix {
        inherit inputs;
        inherit overlays;
      }).activationPackage;
    };
}
