# Module for systems that use the KDE DE

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.system;
in
{
  options.lunik1.system = {
    kde.enable = lib.mkEnableOption "KDE";
    sddm.enable = lib.mkEnableOption "SDDM greeter";
  };

  config = lib.mkIf (cfg.kde.enable || cfg.sddm.enable) {
    assertions = [
      {
        assertion = config.lunik1.system.graphical.enable;
        message = "KDE/SDDM can only be used on graphical systems";
      }
      {
        assertion = !config.lunik1.system.gnome.enable;
        message = "Can only enable GNOME or KDE";
      }
    ];

    # KDE
    services.xserver.desktopManager.plasma5.enable = cfg.kde.enable;
    environment = {
      systemPackages = with pkgs; [
        kio-fuse # TODO broken?
        libsForQt5.kdeconnect-kde
        libsForQt5.plasma-browser-integration
        latte-dock
      ];
      plasma5.excludePackages = with pkgs.libsForQt5; [ elisa ];
    };

    # SDDM
    services.xserver.enable = true;
    services.xserver.displayManager.sddm = lib.mkIf cfg.sddm.enable {
      enable = true;
      autoNumlock = true;
    };
  };
}
