# Zswap configuration

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.zswap;
in {
  options.lunik1.system.zswap.enable = lib.mkEnableOption "Zswap";

  config = lib.mkIf cfg.enable {
    boot = {
      initrd = {
        kernelModules = [ "z3fold" ];
        preDeviceCommands = ''
          printf lzo-rle > /sys/module/zswap/parameters/compressor
          printf z3fold > /sys/module/zswap/parameters/zpool
        '';
      };

      kernel.sysctl."vm.swappiness" = 100; # dont @ me
      kernelParams = [ "zswap.enabled=1" ];
    };
  };
}
