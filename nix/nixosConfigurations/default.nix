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
        ++ (with inputs; [ sops-nix.nixosModules.sops ])
        ++ lib.attrValues outputs.nixosModules;
    };
in
lib.mapAttrs (_: addCommonCfg) (flakelight.importDir ./.)
