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

            lunik1.home = {
              waybar.batteryModule = true;

              core.enable = true;
              cli.enable = true;
              gui.enable = true;

              bluetooth.enable = true;
              emacs.enable = true;
              fonts.enable = true;
              games.cli.enable = true;
              git.enable = true;
              gpg.enable = true;
              megacmd.enable = true;
              mpv.enable = true;
              music.enable = true;
              neovim.enable = true;
              pulp-io.enable = true;
              sway.enable = true;
              syncthing.enable = true;

              lang = {
                c.enable = true;
                clojure.enable = true;
                data.enable = true;
                julia.enable = true;
                nix.enable = true;
                prose.enable = true;
                python.enable = true;
                rust.enable = true;
                sh.enable = true;
                tex.enable = true;
              };
            };
          };
        };
      };
      foureightynine = self.homeConfigurations.foureightynine.activationPackage;
    };
}
