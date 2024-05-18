# Module for systems that use GNOME

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system;
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
      displayManager.defaultSession = "gnome";
      xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager = {
          gdm = {
            enable = true;
            wayland = true;
            autoSuspend = false;
          };
        };
      };
      gnome = {
        gnome-user-share.enable = false;
        games.enable = false;
        # gnome-online-miners.enable = pkgs.lib.mkForce false;
        rygel.enable = false;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        blanket
        gnome.gnome-tweaks
        gnome.dconf-editor
        cartridges
        papers
      ] ++ (with pkgs.gnomeExtensions; [
        appindicator
        dash-to-dock
        hot-edge
        fullscreen-avoider
        gsconnect
        hibernate-status-button
        lock-keys
      ]);
      gnome.excludePackages = (with pkgs; [
        evince
        gedit
        gnome-connections
        gnome-console
        gnome-photos
        gnome-tour
        gnome-usage
        snapshot
      ]) ++ (with pkgs.gnome; [
        baobab
        geary
        gnome-characters
        gnome-clocks
        gnome-disk-utility
        gnome-logs
        gnome-maps
        gnome-music
        gnome-system-monitor
        hitori
        totem
      ]);
    };

    hardware.pulseaudio.enable = false;

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
