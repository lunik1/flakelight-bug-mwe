{
  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11-small";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    lunik1-nur-unstable = {
      url = "github:lunik1/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs@{ self, ... }:
    with inputs;
    with nixpkgs-unstable.lib;
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
        emacs-overlay.overlays.default
      ];
      homeConfigDir = ./home-configurations;
      systemConfigDir = ./systems;
      isNixFile = file: type: (hasSuffix ".nix" file && type == "regular");
      pkgsForSystem = system:
        import nixpkgs-unstable {
          inherit overlays system;
          config = {
            allowUnfree = true;
            packageOverrides = pkgs: {
              lunik1-nur = import lunik1-nur-unstable { inherit pkgs; };
            };
          };
        };
    in {
      nixosConfigurations = mapAttrs' (file: _: {
        name = (removeSuffix ".nix" file);
        value = inputs.nixos.lib.nixosSystem
          ((import (systemConfigDir + "/${file}")) overlays);
      }) (filterAttrs isNixFile (builtins.readDir systemConfigDir));
      homeConfigurations = mapAttrs' (file: _: {
        name = (removeSuffix ".nix" file);
        value = (home-manager.lib.homeManagerConfiguration
          ((import (homeConfigDir + "/${file}"))
            pkgsForSystem)).activationPackage;
      }) (filterAttrs isNixFile (builtins.readDir homeConfigDir));
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsForSystem system;
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
            cachix
            coreutils
            gawk
            jq
            nixfmt
            nix-info
            # nix-linter # does not build, broken
            nixpkgs-lint
            pre-commit
            shellcheck
          ];
        };
      });
}
