# Global and misc options

{ config, lib, pkgs, ... }:

{
  options.lunik1.home = with lib; {
    # This option (should) ensure that this flake installs even if the system
    # doesn't have my private GPG key (any config that needs it will be ignored)
    gpgKeyInstalled = mkOption {
      default = true;
      description = "Does this system have my GnuPG key?";
      type = types.bool;
    };

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
