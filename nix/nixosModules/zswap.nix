# Zswap configuration

{ config, lib, ... }:

let
  cfg = config.lunik1.system.zswap;
in
{
  options.lunik1.system.zswap.enable = lib.mkEnableOption "Zswap";

  config = lib.mkIf cfg.enable {
    boot = {
      initrd = {
        kernelModules = [
          "zstd"
          "z3fold"
        ];
        preDeviceCommands = ''
          printf zstd > /sys/module/zswap/parameters/compressor
          printf z3fold > /sys/module/zswap/parameters/zpool
        '';
      };

      kernel.sysctl = {
        "vm.swappiness" = 180; # don't @ me
        "vm.page-cluster" = 0;
      };
      kernelParams = [ "zswap.enabled=1" ];
    };
  };
}
