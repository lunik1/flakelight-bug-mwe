{
  flakelight,
  lib,
  inputs,
  outputs,
  ...
}@args:

let
  addCommonCfg =
    prev:
    prev
    // {
      modules =
        prev.modules
        ++ (with inputs; [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hmbackup";
            };
          }
        ])
        ++ lib.attrValues outputs.nixosModules or { };
    };

  hmModules =
    (with inputs; [
    ])
    ++ lib.attrValues outputs.homeModules;
in
lib.mapAttrs (_name: value: addCommonCfg (value (args // { inherit hmModules; }))) (
  flakelight.importDir ./.
)
