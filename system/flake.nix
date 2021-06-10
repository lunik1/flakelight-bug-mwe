{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05-small";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.foureightynine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = import modules/module-list.nix ++ [{
        lunik1.system = {
          bluetooth.enable = true;
          graphical.enable = true;
          hidpi.enable = true;
          laptop.enable = true;
          network = {
            resolved.enable = true;
            connman.enable = true;
          };
          pulp-io.enable = true;
          sound.enable = true;
          systemd-boot.enable = true;

          systems.foureightynine.enable = true;
        };
      }];
    };
  };
}
