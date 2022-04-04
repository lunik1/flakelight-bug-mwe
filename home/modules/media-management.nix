# Extra media management utilities

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.media-management;
in {
  options.lunik1.home.media-management.enable =
    lib.mkEnableOption "media-management utilities";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      keyfinder-cli # TODO use path in beet config rather than install globally
      (beets.override {
        enableAlternatives = true;
        enableAura = false;
        enableEmbyupdate = false;
        enableKodiupdate = false;
        enableMpd = false;
        enableSonosUpdate = false;
        enableSubsonicplaylist = false;
        enableThumbnails = false;
        enableSubsonicupdate = false;
        enableLoadext = false;
        enablePlaylist = false;
        # enableWeb = false;  # build fails on 21.05
      })
      mediainfo
      mkvtoolnix-cli
      vobsub2srt
      ytmdl
    ];

    xdg = {
      enable = true;
      configFile.beets_config = {
        source = ../config/beets/config.yaml;
        target = "beets/config.yaml";
      };
    };
  };
}
