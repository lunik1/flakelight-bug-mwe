{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs@{ self, ... }: {
    homeConfigurations = {
      foureightynine = inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        username = "corin";
        homeDirectory = "/home/corin";
        configuration = { pkgs, ... }: {
          nixpkgs.config.allowUnfree = true;
          imports = [ ./home.nix ];
        };
      };
    };
    foureightynine = self.homeConfigurations.foureightynine.activationPackage;
  };
}
