{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05-small";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = { flake-utils.follows = "flake-utils"; };
    };
  };

  outputs = inputs@{ self, ... }:
    with inputs;
    with nixpkgs.lib;
    let
      isNixFile = file: type: (hasSuffix ".nix" file && type == "regular");
      configDir = ./systems;
    in {
      nixosConfigurations = mapAttrs' (file: _: {
        name = (removeSuffix ".nix" file);
        value = nixosSystem (import (configDir + "/${file}"));
      }) (filterAttrs isNixFile (builtins.readDir configDir));
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
            pre-commit
            shellcheck
          ];
        };
      });
}
