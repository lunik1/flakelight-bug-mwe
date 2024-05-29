# Global and misc options

{ lib, ... }:

{
  options.lunik1.home = with lib; {
    # This option allows the configuration to check if it is running on
    # vpsAdminOS. Some programs need slight tweaks to their configuration in
    # that case to prevent misbegaviour
    vpsAdminOs = mkOption {
      default = false;
      description = "Is this system running on vpsAdminOS?";
      type = types.bool;
    };
  };
}
