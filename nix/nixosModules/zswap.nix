# Zswap configuration

{ config, lib, ... }:

let
  cfg = config.lunik1.system.zswap;
in
{
  options.lunik1.system.zswap.enable = lib.mkEnableOption "Zswap";

  config = lib.mkIf cfg.enable {
    boot = {
      kernel.sysctl = {
        "vm.swappiness" = 180; # don't @ me
        "vm.page-cluster" = 0;
      };
      kernelParams = [ "zswap.enabled=1" ];
    };
  };
}
