{ flakelight, lib, inputs, outputs, ... }:

let
  addCommonCfg = prev: prev // {
    modules = prev.modules ++ (with inputs; [
      sops-nix.nixosModules.sops
      lunik1-nur.nixosModules.inadyn
    ]) ++ lib.attrValues outputs.nixosModules;
  };
in
lib.mapAttrs (_: addCommonCfg) (flakelight.importDir ./.)
