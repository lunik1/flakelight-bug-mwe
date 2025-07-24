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
          sops-nix.nixosModules.sops
        ])
        ++ lib.attrValues outputs.nixosModules;
    };

  hmModules =
    (with inputs; [
      nix-index-database.homeModules.nix-index
      nixvim.homeManagerModules.nixvim
      sops-nix.homeManagerModule
    ])
    ++ lib.attrValues outputs.homeModules;
in
lib.mapAttrs (_name: value: addCommonCfg (value (args // { inherit hmModules; }))) (
  flakelight.importDir ./.
)
