# Module for systems that use GNOME

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
    gnome.enable = lib.mkEnableOption "GNOME";
  };

  config = lib.mkIf cfg.gnome.enable {
    assertions = [
      {
        assertion = config.lunik1.system.graphical.enable;
        message = "GNOME can only be used on graphical systems";
      }
      {
        assertion = !config.lunik1.system.kde.enable;
        message = "Can only enable GNOME or KDE";
      }
    ];

    # GNOME
    services = {
      displayManager = {
        defaultSession = "gnome";
        gdm = {
          enable = true;
          wayland = true;
          autoSuspend = false;
        };
      };
      desktopManager.gnome.enable = true;
      gnome = {
        gnome-user-share.enable = false;
        games.enable = false;
        gcr-ssh-agent.enable = false;
        # gnome-online-miners.enable = pkgs.lib.mkForce false;
        rygel.enable = false;
      };
    };

    environment = {
      systemPackages =
        with pkgs;
        [
          blanket
          cartridges
          dconf-editor
          gnome-tweaks
          papers
          read-it-later
        ]
        ++ (with pkgs.gnomeExtensions; [
          appindicator
          dash-to-dock
          hot-edge
          fullscreen-avoider
          gsconnect
          power-off-options
          lock-keys
        ]);
      gnome.excludePackages = with pkgs; [
        baobab
        evince
        geary
        gedit
        gnome-characters
        gnome-clocks
        gnome-connections
        gnome-console
        gnome-disk-utility
        gnome-logs
        gnome-maps
        gnome-music
        gnome-photos
        gnome-system-monitor
        gnome-tour
        gnome-usage
        hitori
        snapshot
        totem
      ];
    };

    programs = {
      gnome-disks.enable = config.services.udisks2.enable;
      seahorse.enable = true;
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };
  };
}
