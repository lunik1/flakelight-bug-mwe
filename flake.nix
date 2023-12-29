{

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.11-small";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    lunik1-nur-unstable = {
      url = "github:lunik1/nur-packages";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    lunik1-nur = {
      url = "github:lunik1/nur-packages";
      inputs = {
        nixpkgs.follows = "nixos";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixos";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-wallpaper = {
      url = "github:lunik1/nix-wallpaper";
      inputs = {
        nixpkgs.follows = "nixos";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
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
      hmModules = [
        nix-index-database.hmModules.nix-index
        sops-nix.homeManagerModule
      ];
      homeConfigDir = ./home-configurations;
      systemConfigDir = ./systems;
      isNixFile = file: type: (hasSuffix ".nix" file && type == "regular");
      pkgsForSystem = system:
        import inputs.nixos {
          inherit system;
          config = {
            allowUnfree = true;
            packageOverrides = pkgs: {
              lunik1-nur = import lunik1-nur { inherit pkgs; };
            };
            neovim = pkgs.neovim.override {
              vimAlias = true;
              viAlias = true;
            };
          };
        };
      pkgsForHome = system:
        import nixpkgs-unstable {
          inherit overlays system;
          config = {
            allowUnfree = true;
            packageOverrides = pkgs: {
              lunik1-nur = import lunik1-nur-unstable { inherit pkgs; };
              nix-wallpaper = nix-wallpaper.packages.${system}.default;
            };
          };
        };
      overlays = [
        (self: super: { yt-dlp = super.yt-dlp.override { withAlias = true; }; })
        (self: super: {
          neovim = super.neovim.override {
            vimAlias = true;
            viAlias = true;
          };
        })
      ];
    in
    {
      nixosConfigurations = mapAttrs'
        (file: _: {
          name = removeSuffix ".nix" file;
          value = inputs.nixos.lib.nixosSystem
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
              { inherit hmModules pkgsForHome; })).activationPackage;
        })
        (filterAttrs isNixFile (builtins.readDir homeConfigDir));
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsForHome system;
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
