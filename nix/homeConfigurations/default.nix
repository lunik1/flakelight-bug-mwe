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
          nix-index-database.hmModules.nix-index
          sops-nix.homeManagerModule
        ])
        ++ lib.attrValues outputs.homeModules;
    };
in
lib.mapAttrs (_: addCommonCfg) (flakelight.importDir ./.)
