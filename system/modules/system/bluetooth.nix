# System bluetooth configuration

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.bluetooth;
in {
  options.lunik1.system.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # passwordless access to rfkill without sudo so bluetooth can be toggled
    security.sudo.extraRules = [{
      groups = [ "wheel" ];
      commands = [{
        command = "/run/current-system/sw/bin/rfkill";
        options = [ "NOPASSWD" ];
      }];
    }];
  };
}
