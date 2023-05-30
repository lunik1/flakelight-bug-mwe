# Extra media management utilities

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.media-management;
in {
  options.lunik1.home.media-management.enable =
    lib.mkEnableOption "media-management utilities";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (beets.override {
        pluginOverrides.alternatives = {
          enable = true;
          propagatedBuildInputs = [ pkgs.beetsPackages.alternatives ];
        };
      })
      calibre
      flac
      keyfinder-cli # TODO use path in beet config rather than install globally
      mediainfo
      mkvtoolnix-cli
      vobsub2srt
      ytmdl
    ];

    xdg = {
      enable = true;
      configFile = {
        beets_config = {
          source = ../../config/beets/config.yaml;
          target = "beets/config.yaml";
        };
        ytmdl = {
          text = ''
            DEFAULT_FORMAT = "opus"
          '';
          target = "ytmdl/config";
        };
      };
    };
  };
}
