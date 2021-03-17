{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, ... }:
    let
      # nixos-unstable-overlay = final: prev: {
      #   nixos-unstable = import inputs.nixos-unstable {
      #     system = prev.system;
      #     # config.allowUnfree = true;
      #     overlays = [ inputs.emacs-overlay.overlay ];
      #   };
      # };
      overlays = [
        # nixos-unstable-overlay
        (self: super: {
          youtube-dl = super.youtube-dl.override { phantomjsSupport = true; };
        })
      ];
    in {
      homeConfigurations = {
        foureightynine = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          username = "corin";
          homeDirectory = "/home/corin";
          configuration = { pkgs, ... }: {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
            home.stateVersion = "20.09";
            imports = [ ./home.nix ];
          };
        };
      };
      foureightynine = self.homeConfigurations.foureightynine.activationPackage;
    };
}
