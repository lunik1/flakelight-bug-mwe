# Enable locate

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lunik1.system.locate;
in {
  options.lunik1.system.locate = with types; {
    enable = mkEnableOption "locate";
    interval = mkOption {
      type = str;
      default = "14:15";
      description = "locate update interval, see services.locate.interval";
    };
  };

  config = lib.mkIf cfg.enable {
    services.locate = {
      enable = true;
      locate = pkgs.mlocate;
      interval = cfg.interval;
      localuser = null;
    };

    users.users.corin.extraGroups = [ "mlocate" ];
  };
}
