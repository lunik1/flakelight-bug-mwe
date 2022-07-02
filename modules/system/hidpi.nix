# Settings for systems with HiDPI displays

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.hidpi;
in {
  options.lunik1.system.hidpi.enable = lib.mkEnableOption "HiDPI configuration";

  config = lib.mkIf cfg.enable {
    hardware.video.hidpi.enable = true;
    fonts.fontconfig.hinting.enable = false;
  };
}
