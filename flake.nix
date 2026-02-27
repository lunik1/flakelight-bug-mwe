{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakelight = {
      url = "github:nix-community/flakelight";
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
      {
        systems = [
          "x86_64-linux"
        ];

        withOverlays = [
          (self: super: { lib = super.lib.recursiveUpdate super.lib { lunik1.myTrue = true; }; })
        ];
      }
    );
}
