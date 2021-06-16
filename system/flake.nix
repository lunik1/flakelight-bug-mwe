{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05-small";

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      foureightynine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ (import systems/foureightynine.nix) ];
      };
      dionysus2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ (import systems/dionysus2.nix) ];
      };
    };
  };
}
