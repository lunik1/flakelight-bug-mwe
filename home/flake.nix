{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url =
        "github:nix-community/home-manager/2917ef23b398a22ee33fb34b5766b28728228ab1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
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
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs@{ self, ... }:
    let
      overlays = [
        (self: super: {
          youtube-dl = super.youtube-dl.override { phantomjsSupport = true; };
          yt-dlp = super.yt-dlp.override {
            phantomjsSupport = true;
            withAlias = true;
          };
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
        (self: super: {
          mpv-youtube-quality = super.mpvScripts.youtube-quality.overrideAttrs
            (old: rec {
              src = super.fetchFromGitHub {
                owner = "christoph-heinrich";
                repo = "mpv-youtube-quality";
                rev = "7562cc0fd7bbd3b5ff056e416aeb7117abf62079";
                sha256 = "BduHK4OUYQHps3XHxudzsF1OTbygEKA5yQnEcDtyI4E=";
              };
            });
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
      vegas = (import home-configurations/vegas.nix {
        inherit inputs;
        inherit overlays;
      }).activationPackage;
      tucson = (import home-configurations/tucson.nix {
        inherit inputs;
        inherit overlays;
      }).activationPackage;
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = inputs.nixpkgs.legacyPackages.${system};
      in {
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              shellcheck.enable = true;
            };
          };
        };
        devShell = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = with pkgs; [
            nixfmt
            nix-linter
            nixpkgs-lint
            shellcheck
          ];
        };
      });
}
