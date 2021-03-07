{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  outputs = { self, nixpkgs }: {
    nixosConfigurations.foureightynine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
