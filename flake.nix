{

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05-small";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    lunik1-nur-unstable = {
      url = "github:lunik1/nur-packages";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
        nixpkgs-lint.follows = "nixpkgs-lint";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    bach = {
      url = "gitlab:lunik1/bach";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
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
        nixpkgs-stable.follows = "nixos";
        flake-utils.follows = "flake-utils";
      };
    };
    nixpkgs-lint = {
      url = "github:nix-community/nixpkgs-lint";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs@{ self, ... }:
    with inputs;
    with nixpkgs-unstable.lib;
    let
      hmModules = [ nix-index-database.hmModules.nix-index ];
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
              bach = bach.packages.${system}.bach;
            };
          };
        };
      overlays = [
        (import ./lib/overlay.nix)
        (self: super: { yt-dlp = super.yt-dlp.override { withAlias = true; }; })
        (self: super:
          # TODO: move to NUR
          {
            iosevka25 = self.iosevka.override
              rec {
                buildNpmPackage = args: super.buildNpmPackage
                  (args // rec {
                    version = "25.0.1";
                    src = super.fetchFromGitHub {
                      owner = "be5invis";
                      repo = "iosevka";
                      rev = "v${version}";
                      hash = "sha256-clbqr4hGtIkbgPYovYXHGW+FUTEjAn3Oq7aoPFMgGJU=";
                    };
                    npmDepsHash = "sha256-TxMmUgwQPbSV+1qe0FEtSPAYwJRnpuQ+qOmWvrq9xKY=";
                  });
              };
            myosevka = self.iosevka25.override {
              privateBuildPlan = import resources/iosevka/myosevka.nix;
              set = "myosevka";
            };
            myosevka-proportional = self.iosevka25.override {
              privateBuildPlan =
                import resources/iosevka/myosevka-proportional.nix;
              set = "myosevka-proportional";
            };
            myosevka-aile = self.iosevka25.override {
              privateBuildPlan = (import resources/iosevka/myosevka-aile.nix) {
                inherit (super) lib;
              };
              set = "myosevka-aile";
            };
            myosevka-etoile = self.iosevka25.override {
              privateBuildPlan = (import resources/iosevka/myosevka-etoile.nix) {
                inherit (super) lib;
              };
              set = "myosevka-etoile";
            };
          })
        (self: super: {
          inherit LS_COLORS;
        })
        (self: super: { inherit firefox-lepton; })
        (self: super: {
          neovim = super.neovim.override {
            vimAlias = true;
            viAlias = true;
          };
        })
        (self: super: { inherit nixos-logo-gruvbox-wallpaper; })
        emacs-overlay.overlays.default
        nixpkgs-lint.overlays.default
      ];
    in
    {
      nixosConfigurations = mapAttrs'
        (file: _: {
          name = removeSuffix ".nix" file;
          value = inputs.nixos.lib.nixosSystem
            ((import (systemConfigDir + "/${file}")) overlays);
        })
        (filterAttrs isNixFile (builtins.readDir systemConfigDir));
      homeConfigurations = mapAttrs'
        (file: _: {
          name = removeSuffix ".nix" file;
          value = (home-manager.lib.homeManagerConfiguration
            ((import (homeConfigDir + "/${file}"))
              { inherit hmModules pkgsForSystem; })).activationPackage;
        })
        (filterAttrs isNixFile (builtins.readDir homeConfigDir));
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsForSystem system;
      in
      {
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              shellcheck.enable = true;
            };
          };
        };
        formatter = pkgs.nixpkgs-fmt;
        devShell = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          packages = with pkgs; [
            cachix
            coreutils
            gawk
            jq
            nixpkgs-fmt
            nix-info
            nixpkgs-lint
            pre-commit
            shellcheck
            statix
          ];
        };
      });
}
