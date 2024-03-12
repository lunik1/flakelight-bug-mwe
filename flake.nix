{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lunik1-nur = {
      url = "github:lunik1/nur-packages";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-wallpaper = {
      url = "github:lunik1/nix-wallpaper";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    flake-utils.url = "github:numtide/flake-utils";
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
      hmModules = [
        nix-index-database.hmModules.nix-index
        sops-nix.homeManagerModule
      ];
      homeConfigDir = ./home-configurations;
      systemConfigDir = ./systems;
      isNixFile = file: type: (hasSuffix ".nix" file && type == "regular");
      overlays = [
        (self: super: { yt-dlp = super.yt-dlp.override { withAlias = true; }; })
        (self: super: {
          neovim = super.neovim.override {
            vimAlias = true;
            viAlias = true;
          };
        })
        (self: super: {
          gnome = super.gnome.overrideScope' (gnomeFinal: gnomePrev: {
            mutter = gnomePrev.mutter.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                (super.fetchpatch {
                  url = "https://gist.githubusercontent.com/lunik1/3428ca679d5c7c0bd3b791f8b4a605c4/raw/234f3717047e8d90fc2d386192526bac1ee54c98/mutter-vrr.patch";
                  sha256 = "sha256-YpX+DK7BvHAnVSfOvtudb3bpMcU6bsNw8PI+b4hj/eU=";
                })
              ];
            });
            gnome-control-center = gnomePrev.gnome-control-center.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                (super.fetchpatch {
                  url = "https://gist.githubusercontent.com/lunik1/43d5d6b114084f087cb248aafea75f2e/raw/26e5c37df85ddf75f2070eafcfc42865b2a164f8/gnome-control-ceter-vrr.patch";
                  sha256 = "sha256-QSi3KlNA2DSMp7B8lpval+nlCqREK9Ch1Kj2kaGq+QM=";
                })
              ];
            });
          });
        })
      ];
      pkgsForSystem = system:
        import nixpkgs {
          inherit overlays system;
          config = {
            # Needed for MEGAcmd/sync, unfortunately
            permittedInsecurePackages = [
              "freeimage-unstable-2021-11-01"
            ];
            allowUnfree = true;
            packageOverrides = pkgs: {
              lunik1-nur = import lunik1-nur { inherit pkgs; };
              nix-wallpaper = nix-wallpaper.packages.${system}.default;
              neovim = pkgs.neovim.override {
                vimAlias = true;
                viAlias = true;
              };
            };
          };
        };
    in
    {
      nixosConfigurations = mapAttrs'
        (file: _: {
          name = removeSuffix ".nix" file;
          value = nixpkgs.lib.nixosSystem
            ((import (systemConfigDir + "/${file}"))
              {
                inherit pkgsForSystem;
                modules = [
                  inputs.sops-nix.nixosModules.sops
                  lunik1-nur.nixosModules.inadyn
                ];
              });
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
            nixpkgs-lint-community
            nodePackages_latest.yaml-language-server
            pre-commit
            shellcheck
            sops
            ssh-to-age
            statix
          ];
        };
      });
}
