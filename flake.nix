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
    wbba.url = "github:sohalt/write-babashka-application";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
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

  outputs =
    { flakelight, ... }:
    flakelight ./. (
      { lib, inputs, ... }:
      with lib;
      let
        nixpkgsConfig = {
          allowUnfree = true;
        };

        withOverlays = [
          inputs.wbba.overlays.default
          (self: super: { lunik1-nur = import inputs.lunik1-nur { pkgs = super; }; })
          (self: super: { nix-wallpaper = super.inputs'.nix-wallpaper.packages.default; })
          (self: super: {
            rmlint = super.rmlint.overrideAttrs (
              final: old: {
                patches = old.patches ++ [
                  (super.fetchpatch {
                    url = "https://github.com/sahib/rmlint/commit/f0ca57ec907f7199e3670038d60b4702d1e1d8e2.patch";
                    hash = "sha256-715X+R2BcQIaUV76hoO+EXPfNheOfw4OIHsqSoruIUI=";
                  })
                ];
              }
            );
          })
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
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        flakelight.builtinFormatters = false;

        nixpkgs.config = {
          allowUnfree = true;
        };

        inherit withOverlays;

        overlay = foldl' lib.composeExtensions (_: _: { }) withOverlays;

        formatters =
          pkgs: with pkgs; {
            "*.nix" = "${nixfmt-rfc-style}/bin/nixfmt";
            "*.bb" = "${cljfmt}/bin/cljfmt";
          };

        checks = {
          pre-commit-check =
            pkgs:
            pkgs.inputs'.pre-commit-hooks.lib.run {
              src = ./.;
              hooks = {
                nixfmt-rfc-style.enable = true;
                shellcheck.enable = true;
              };
            };
        };

        devShell = pkgs: {
          inherit (pkgs.outputs'.checks.pre-commit-check) shellHook;
          packages = with pkgs; [
            outputs'.packages.ploy

            cachix
            coreutils
            gawk
            jq
            nix-info
            nix-output-monitor
            nixfmt-rfc-style
            nixpkgs-lint-community
            nodePackages_latest.prettier
            nodePackages_latest.yaml-language-server
            pre-commit
            shellcheck
            sops
            ssh-to-age
            statix

            babashka
            clojure-lsp
            clj-kondo
            cljfmt
          ];
        };

        outputs.nixpkgsConfig = nixpkgsConfig;

        license = lib.licenses.bsd2Patent;
      }
    );
}
