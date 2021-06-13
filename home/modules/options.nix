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
  };
}
