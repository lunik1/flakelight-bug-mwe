{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
    with inputs;
    with nixpkgs.lib;
    let
      overlays = [
        (self: super: { yt-dlp = super.yt-dlp.override { withAlias = true; }; })
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
        (self: super: { LS_COLORS = LS_COLORS; })
        (self: super: { firefox-lepton = firefox-lepton; })
        (self: super: {
          neovim = super.neovim.override {
            vimAlias = true;
            viAlias = true;
          };
        })
        (self: super: {
          nixos-logo-gruvbox-wallpaper = nixos-logo-gruvbox-wallpaper;
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
              postPatch = ''
                substituteInPlace youtube-quality.lua \
                --replace '"yt-dlp"' '"${super.yt-dlp}/bin/yt-dlp"';
              '';
            });
        })
      ];
      configDir = ./home-configurations;
      isNixFile = file: type: (hasSuffix ".nix" file && type == "regular");
      pkgsForSystem = system:
        import nixpkgs {
          inherit overlays system;
          config = {
            allowUnfree = true;
            # https://github.com/nix-community/home-manager/issues/2942 workaround
            allowUnfreePredicate = (_: true);
          };
        };
    in {
      homeConfigurations = mapAttrs' (file: _: {
        # create an attrset of hostname = config pairs
        name = (removeSuffix ".nix" file);
        value = (home-manager.lib.homeManagerConfiguration
          ((import (configDir + "/${file}")) pkgsForSystem)).activationPackage;
      }) (filterAttrs isNixFile (builtins.readDir configDir));
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
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
            pre-commit
            shellcheck
          ];
        };
      });
}
