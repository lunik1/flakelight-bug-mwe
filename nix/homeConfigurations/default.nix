{
  flakelight,
  lib,
  inputs,
  outputs,
  ...
}:

let
  addCommonCfg =
    prev:
    prev
    // {
      modules =
        prev.modules
        ++ (with inputs; [
          nix-index-database.homeModules.nix-index
          nixvim.homeManagerModules.nixvim
          sops-nix.homeManagerModule
        ])
        ++ lib.attrValues outputs.homeModules;
    };
in
lib.mapAttrs (_: addCommonCfg) (flakelight.importDir ./.)
