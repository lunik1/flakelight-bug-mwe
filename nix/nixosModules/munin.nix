# Munin system monitoring

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.system.munin;
in
{
  options.lunik1.system.munin.enable = lib.mkEnableOption "munin";

  config = lib.mkIf cfg.enable {
    services = {
      munin-node.enable = true;
      munin-cron = {
        enable = true;
        hosts = ''
          [${config.networking.hostName}]
          address localhost
        '';
      };
    };
  };
}
