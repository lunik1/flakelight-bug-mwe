# Setup for systemd-boot bootloader

{ config, lib, ... }:

let
  cfg = config.lunik1.system.systemd-boot;
in
{
  options.lunik1.system.systemd-boot.enable = lib.mkEnableOption "systemd-boot";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.lunik1.system.grub.enable;
        message = "You cannot enable systemd-boot and GRUB.";
      }
    ];

    boot.loader.systemd-boot = {
      enable = true;
      memtest86.enable = true;
      editor = false;
      consoleMode = "max";
      configurationLimit = 25;
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
