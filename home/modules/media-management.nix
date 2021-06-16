# Extra media management utilities

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.media-management;
in {
  options.lunik1.home.media-management.enable =
    lib.mkEnableOption "media-management utilities";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      beets.override
      {
        enableAlternatives = true;
        enableEmbyupdate = false;
        enableKodiupdate = false;
        enableMpd = false;
        enableSonosUpdate = false;
        enableKeyfinder = true;
        # enableWeb = false;  # build fails on 20.09
        # enableCheck = true;  # stack overflow on 20.09
      }
      mediainfo
      mkvtoolnix-cli
      vobsub2srt
    ];
  };
}
