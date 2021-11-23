# Module for systems that use the KDE DE

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system;
in {
  options.lunik1.system = {
    kde.enable = lib.mkEnableOption "KDE";
    sddm.enable = lib.mkEnableOption "SDDM greeter";
  };

  config = {
    assertions = [{
      assertion = config.lunik1.system.graphical.enable;
      message = "KDE/SDDM can only be used on graphical systems";
    }];

    # KDE
    services.xserver.desktopManager.plasma5.enable = cfg.kde.enable;
    environment.systemPackages = with pkgs; [
      # kio-fuse
      libsForQt5.kdeconnect-kde
      libsForQt5.plasma-browser-integration
    ];

    # SDDM
    services.xserver.enable = true;
    services.xserver.displayManager.sddm = lib.mkIf cfg.sddm.enable {
      enable = true;
      autoNumlock = true;
    };
  };
}
