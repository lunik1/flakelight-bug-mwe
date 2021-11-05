{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05-small";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    {
      nixosConfigurations = {
        foureightynine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ (import systems/foureightynine.nix) ];
        };
        dionysus2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ (import systems/dionysus2.nix) ];
        };
        hermes = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ (import systems/hermes.nix) ];
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              shellcheck.enable = true;
            };
          };
        };
        devShell = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = with pkgs; [
            nixfmt
            nix-linter
            nixpkgs-lint
            shellcheck
          ];
        };
      });
}
