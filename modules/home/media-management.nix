# Extra media management utilities

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.media-management;
in
{
  options.lunik1.home.media-management.enable =
    lib.mkEnableOption "media-management utilities";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      calibre
      flac
      mediainfo
      mkvtoolnix-cli
      vobsub2srt
      ytmdl
    ];

    programs.beets = {
      enable = true;
      package = with pkgs; (beets.override {
        pluginOverrides.alternatives = {
          enable = true;
          propagatedBuildInputs = [ beetsPackages.alternatives ];
        };
      });
      settings = {
        plugins = "acousticbrainz alternatives badfiles bpd chroma convert deezer discogs duplicates fetchart keyfinder lastgenre lyrics mbsync replaygain scrub web zero embedart";
        import.move = true;
        scrub.auto = true;
        keyfinder = {
          auto = true;
          bin = "${pkgs.keyfinder-cli}/bin/keyfinder-cli";
        };
        replaygain = {
          auto = true;
          overwrite = true;
          backend = "ffmpeg";
        };
        embedart.auto = true;
        zero = {
          fields = "comments";
          comments = [ "ripped by" ];
          update_database = true;
        };
        lyrics.sources = "lyricwiki musixmatch genius";
        convert = {
          format = "flac";
          formats = {
            aac = {
              command = "${pkgs.ffmpeg}/bin/ffmpeg -i $source -ac 2 -c:a libfdk_aac -vbr 3 $dest";
              extension = "m4a";
            };
          };
          mp3 = {
            command = "${pkgs.ffmpeg}/bin/ffmpeg -i $source -ac 2 -codec:a libmp3lame -qscale:a 4 $dest";
            extension = "mp3";
          };
          opus = {
            command = "${pkgs.ffmpeg}/bin/ffmpeg -i $source -ac 2 -acodec libopus -b:a 128k -vbr on -compression_level 10 $dest";
            extension = "opus";
          };
          speex = {
            command = "${pkgs.ffmpeg}/bin/ffmpeg -i $source -ac 2 -y -acodec speex $dest";
            extension = "spx";
          };
          vorbis = {
            command = "${pkgs.ffmpeg}/bin/ffmpeg -i $source -ac 2 -codec:a libvorbis -qscale:a 3 $dest";
            extension = "ogg";
          };
          flac = {
            command = "${pkgs.flac}/bin/flac -8sVep $source -o $dest";
            extension = "flac";
          };
          wav = {
            command = "${pkgs.ffmpeg}/bin/ffmpeg -i $source -y -acodec pcm_s16le $dest";
            extension = "wav";
          };
          max_bitrate = 320;
          never_convert_lossy_files = true;
        };
      };
    };

    xdg = {
      enable = true;
      configFile.ytmdl = {
        text = ''
          DEFAULT_FORMAT = "opus"
        '';
        target = "ytmdl/config";
      };
    };
  };
}
