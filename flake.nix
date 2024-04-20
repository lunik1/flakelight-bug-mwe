{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lunik1-nur = {
      url = "github:lunik1/nur-packages";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { flakelight, ... }:
    flakelight ./. ({ lib, inputs, ... }:
      with lib;
      {
        flakelight.builtinFormatters = false;

        nixpkgs.config = {
          allowUnfree = true;
        };

        withOverlays = [
          (self: super: {
            gnome = super.gnome.overrideScope (gnomeFinal: gnomePrev: {
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
          (self: super: { lunik1-nur = import inputs.lunik1-nur { pkgs = super; }; })
          (self: super: { nix-wallpaper = super.inputs'.nix-wallpaper.packages.default; })
          (self: super: { yt-dlp = super.yt-dlp.override { withAlias = true; }; })
          (self: super: {
            neovim = super.neovim.override {
              vimAlias = true;
              viAlias = true;
            };
          })
        ];

        formatters = pkgs: with pkgs; {
          "*.nix" = "${nixpkgs-fmt}/bin/nixpkgs-fmt";
        };

        checks = {
          pre-commit-check = pkgs: pkgs.inputs'.pre-commit-hooks.lib.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              shellcheck.enable = true;
            };
          };
        };

        devShell = pkgs: {
          inherit (pkgs.outputs'.checks.pre-commit-check) shellHook;
          packages = with pkgs; [
            cachix
            coreutils
            gawk
            jq
            nixpkgs-fmt
            nix-info
            nixpkgs-lint-community
            nodePackages_latest.prettier
            nodePackages_latest.yaml-language-server
            pre-commit
            shellcheck
            sops
            ssh-to-age
            statix
          ];
        };

        license = lib.licenses.bsd2Patent;
      });
}
