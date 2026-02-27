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
      modules = prev.modules ++ (with inputs; [ ]) ++ lib.attrValues outputs.homeModules or [ ];
    };
in
lib.mapAttrs (_: addCommonCfg) (flakelight.importDir ./.)
