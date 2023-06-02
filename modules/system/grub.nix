# Setup for GRUB bootloader
# You will need to set boot.loader.grub.device!

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.grub;
in {
  options.lunik1.system.grub.enable = lib.mkEnableOption "GRUB";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.lunik1.system.systemd-boot.enable;
        message = "You cannot enable systemd-boot and GRUB.";
      }
      {
        assertion = config.boot.loader.grub.device != "";
        message = "You must set a device to install GRUB on.";
      }
    ];

    boot.loader = {
      grub = {
        enable = true;
        splashImage = null;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
