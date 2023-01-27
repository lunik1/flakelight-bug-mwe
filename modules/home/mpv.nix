# mpv configuration

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.lunik1.home.mpv;
in {
  options.lunik1.home.mpv = with types; {
    enable = mkEnableOption "mpv";
    profile = mkOption {
      default = "potato";
      type = enum [ "potato" "placebo" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ playerctl plex-mpv-shim xdg_utils ];

    programs.mpv = rec {
      enable = true;
      scripts = with pkgs.mpvScripts;
        [ autoload mpris mpv-playlistmanager pkgs.lunik1-nur.quality-menu ]
        ++ lib.optional (cfg.profile == "placebo") thumbnail;
      config = with cfg;
        {
          # Video
          vo = "gpu";
          video-output-levels = "full";
          screenshot-format = "webp";
          screenshot-webp-lossless = "yes";
          screenshot-webp-compression = 6;
          screenshot-tag-colorspace = "yes";
          screenshot-high-bit-depth = "yes";
          vlang = "enGB,en-GB,eng,en,english,enUS,en-US,jpn,jp";
          hwdec-codecs = "all";
          gpu-api = "opengl";
          video-latency-hacks = "yes";
          gamma-factor = 1.1;
          temporal-dither = "yes";
          dither-depth = "auto";
          sigmoid-upscaling = "yes";
          scaler-resizes-only = "yes";
          sws-scaler = "x";
          scaler-lut-size = 10;

          # Audio
          ao = "pipewire";
          audio-channels = "auto";
          volume-max = 200;
          alang = "enGB,en-GB,eng,en,english,enUS,en-US,jpn,jp";
          audio-file-auto = "fuzzy";
          ad-lavc-threads = 0;

          # Subtitles
          sub-ass-vsfilter-color-compat = "full";
          sub-ass-vsfilter-aspect-compat = "no";
          sub-ass-force-style = "Kerning=yes";
          demuxer-mkv-subtitle-preroll = "yes";
          sub-auto = "fuzzy";
          slang = "enGB,en-GB,eng,en,english,enUS,en-US";
          sid = "auto";
          subs-with-matching-audio = "no";
          sub-fix-timing = "yes";
          sub-file-paths = "sub";
          sub-gauss = 0.75;
          sub-gray = "yes";
          blend-subtitles = "yes";

          # Playback
          demuxer-cache-wait = "no";
          hr-seek-framedrop = "no";

          # Window
          geometry = "50%:50%";
          autofit = "90%x90%";
          autofit-larger = "90%x90%";

          # UI
          msg-color = "yes";
          term-osd-bar = "yes";
          osc = if elem pkgs.mpvScripts.thumbnail scripts then "no" else "yes";

          # Behaviour
          keep-open = "yes";
          idle = "yes";
          cache = "auto";
          cache-on-disk = "yes";
          cache-dir = "/tmp";
          demuxer-readahead-secs = 20;
          demuxer-max-bytes = "10GiB";
          force-window = "yes";
          no-resume-playback = "";
        } // optionalAttrs (profile == "potato") {
          vo = "gpu";
          scale = "bicubic_fast";
          cscale = "bicubic_fast";
          dscale = "bilinear";
          scale-antiring = 0.7;
          cscale-antiring = 0.7;
          sigmoid-upscaling = "yes";
          deband = "no";
          vd-lavc-skiploopfilter = "bidir";

          hwdec = "auto-safe";

          ytdl-format = "bestvideo[height<=1080]+bestaudio/best[height<=1080]";
        } // optionalAttrs (profile == "placebo") {
          profile = "gpu-hq";
          scale = "ewa_lanczos";
          cscale = "ewa_lanczos";
          dscale = "mitchell";
          linear-downscaling = "no";
          correct-downscaling = "yes";

          deband = "yes";
          deband-iterations = 4;
          deband-range = 8;

          icc-profile-auto = "";
          icc-3dlut-size = "266x256x256";
          # icc-cache-dir = "~/.cache/mpv/icc";

          glsl-shaders = "${../../resources/mpv/shaders/KrigBilateral.glsl}:${
              ../../resources/mpv/shaders/FSRCNNX_x2_16-0-4-1.glsl
            }:${../../resources/mpv/shaders/SSimDownscaler.glsl}:${
              ../../resources/mpv/shaders/FSRCNNX_x2_16-0-4-1.glsl
            }";

          ytdl-format = "bestvideo+bestaudio/best";
        };
      bindings = {
        "F" = "script-binding quality_menu/video_formats_toggle";
        "Alt+f" = "script-binding quality_menu/audio_formats_toggle";
        "Ctrl+h" = ''cycle-values hwdec "auto-copy-safe" "auto-safe" "no"'';
        "Ctrl++" = "add audio-delay 0.100";
        "x" = "add audio-delay -0.1";
        "X" = "add audio-delay +0.1";
      };
      profiles = {
        "protocol.http" = {
          hls-bitrate = "max";
          cache = "yes";
          cache-on-disk = "yes";
          demuxer-max-bytes = "4000MiB";
          demuxer-max-back-bytes = "4000MiB";
        };
        "protocol.https" = { profile = "protocol.http"; };
        "protocol.ytdl" = { profile = "protocol.http"; };
        "protocol.smb" = { profile = "protocol.http"; };
      };
    };

    services.playerctld.enable = true;

    xdg = {
      enable = true;
      configFile = {
        "autocrop.lua" = {
          source = "${pkgs.mpv-unwrapped.src.outPath}/TOOLS/lua/autocrop.lua";
          target = "mpv/scripts/autocrop.lua";
        };
        "autocrop.conf" = {
          text = "auto=no";
          target = "mpv/script-opts/autocrop.conf";
        };
        "autodeint.lua" = {
          source = "${pkgs.mpv-unwrapped.src.outPath}/TOOLS/lua/autodeint.lua";
          target = "mpv/scripts/autodeint.lua";
        };
        "mpv_thumbnail_script.conf" = {
          text = ''
            autogenerate_max_duration=18000
            thumbnail_network=yes
          '';
          target = "mpv/script-opts/mpv_thumbnail_script.conf";
        };
        "youtube-quality.conf" = {
          text = "style_ass_tags={\\fnmonospace\\fs50}";
          target = "mpv/script-opts/youtube-quality.conf";
        };
        "ytdl_hook.conf" = {
          text = "ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp";
          target = "mpv/script-opts/ytdl_hook.conf";
        };
      };
      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/ogg" = [ "mpv.desktop" ];
          "application/x-ogg" = [ "mpv.desktop" ];
          "application/mxf" = [ "mpv.desktop" ];
          "application/sdp" = [ "mpv.desktop" ];
          "application/smil" = [ "mpv.desktop" ];
          "application/x-smil" = [ "mpv.desktop" ];
          "application/streamingmedia" = [ "mpv.desktop" ];
          "application/x-streamingmedia" = [ "mpv.desktop" ];
          "application/vnd.rn-realmedia" = [ "mpv.desktop" ];
          "application/vnd.rn-realmedia-vbr" = [ "mpv.desktop" ];
          "audio/aac" = [ "mpv.desktop" ];
          "audio/x-aac" = [ "mpv.desktop" ];
          "audio/vnd.dolby.heaac.1" = [ "mpv.desktop" ];
          "audio/vnd.dolby.heaac.2" = [ "mpv.desktop" ];
          "audio/aiff" = [ "mpv.desktop" ];
          "audio/x-aiff" = [ "mpv.desktop" ];
          "audio/m4a" = [ "mpv.desktop" ];
          "audio/x-m4a" = [ "mpv.desktop" ];
          "application/x-extension-m4a" = [ "mpv.desktop" ];
          "audio/mp1" = [ "mpv.desktop" ];
          "audio/x-mp1" = [ "mpv.desktop" ];
          "audio/mp2" = [ "mpv.desktop" ];
          "audio/x-mp2" = [ "mpv.desktop" ];
          "audio/mp3" = [ "mpv.desktop" ];
          "audio/x-mp3" = [ "mpv.desktop" ];
          "audio/mpeg" = [ "mpv.desktop" ];
          "audio/mpeg2" = [ "mpv.desktop" ];
          "audio/mpeg3" = [ "mpv.desktop" ];
          "audio/mpegurl" = [ "mpv.desktop" ];
          "audio/x-mpegurl" = [ "mpv.desktop" ];
          "audio/mpg" = [ "mpv.desktop" ];
          "audio/x-mpg" = [ "mpv.desktop" ];
          "audio/rn-mpeg" = [ "mpv.desktop" ];
          "audio/musepack" = [ "mpv.desktop" ];
          "audio/x-musepack" = [ "mpv.desktop" ];
          "audio/ogg" = [ "mpv.desktop" ];
          "audio/scpls" = [ "mpv.desktop" ];
          "audio/x-scpls" = [ "mpv.desktop" ];
          "audio/vnd.rn-realaudio" = [ "mpv.desktop" ];
          "audio/wav" = [ "mpv.desktop" ];
          "audio/x-pn-wav" = [ "mpv.desktop" ];
          "audio/x-pn-windows-pcm" = [ "mpv.desktop" ];
          "audio/x-realaudio" = [ "mpv.desktop" ];
          "audio/x-pn-realaudio" = [ "mpv.desktop" ];
          "audio/x-ms-wma" = [ "mpv.desktop" ];
          "audio/x-pls" = [ "mpv.desktop" ];
          "audio/x-wav" = [ "mpv.desktop" ];
          "video/mpeg" = [ "mpv.desktop" ];
          "video/x-mpeg2" = [ "mpv.desktop" ];
          "video/x-mpeg3" = [ "mpv.desktop" ];
          "video/mp4v-es" = [ "mpv.desktop" ];
          "video/x-m4v" = [ "mpv.desktop" ];
          "video/mp4" = [ "mpv.desktop" ];
          "application/x-extension-mp4" = [ "mpv.desktop" ];
          "video/divx" = [ "mpv.desktop" ];
          "video/vnd.divx" = [ "mpv.desktop" ];
          "video/msvideo" = [ "mpv.desktop" ];
          "video/x-msvideo" = [ "mpv.desktop" ];
          "video/ogg" = [ "mpv.desktop" ];
          "video/quicktime" = [ "mpv.desktop" ];
          "video/vnd.rn-realvideo" = [ "mpv.desktop" ];
          "video/x-ms-afs" = [ "mpv.desktop" ];
          "video/x-ms-asf" = [ "mpv.desktop" ];
          "audio/x-ms-asf" = [ "mpv.desktop" ];
          "application/vnd.ms-asf" = [ "mpv.desktop" ];
          "video/x-ms-wmv" = [ "mpv.desktop" ];
          "video/x-ms-wmx" = [ "mpv.desktop" ];
          "video/x-ms-wvxvideo" = [ "mpv.desktop" ];
          "video/x-avi" = [ "mpv.desktop" ];
          "video/avi" = [ "mpv.desktop" ];
          "video/x-flic" = [ "mpv.desktop" ];
          "video/fli" = [ "mpv.desktop" ];
          "video/x-flc" = [ "mpv.desktop" ];
          "video/flv" = [ "mpv.desktop" ];
          "video/x-flv" = [ "mpv.desktop" ];
          "video/x-theora" = [ "mpv.desktop" ];
          "video/x-theora+ogg" = [ "mpv.desktop" ];
          "video/x-matroska" = [ "mpv.desktop" ];
          "video/mkv" = [ "mpv.desktop" ];
          "audio/x-matroska" = [ "mpv.desktop" ];
          "application/x-matroska" = [ "mpv.desktop" ];
          "video/webm" = [ "mpv.desktop" ];
          "audio/webm" = [ "mpv.desktop" ];
          "audio/vorbis" = [ "mpv.desktop" ];
          "audio/x-vorbis" = [ "mpv.desktop" ];
          "audio/x-vorbis+ogg" = [ "mpv.desktop" ];
          "video/x-ogm" = [ "mpv.desktop" ];
          "video/x-ogm+ogg" = [ "mpv.desktop" ];
          "application/x-ogm" = [ "mpv.desktop" ];
          "application/x-ogm-audio" = [ "mpv.desktop" ];
          "application/x-ogm-video" = [ "mpv.desktop" ];
          "application/x-shorten" = [ "mpv.desktop" ];
          "audio/x-shorten" = [ "mpv.desktop" ];
          "audio/x-ape" = [ "mpv.desktop" ];
          "audio/x-wavpack" = [ "mpv.desktop" ];
          "audio/x-tta" = [ "mpv.desktop" ];
          "audio/AMR" = [ "mpv.desktop" ];
          "audio/ac3" = [ "mpv.desktop" ];
          "audio/eac3" = [ "mpv.desktop" ];
          "audio/amr-wb" = [ "mpv.desktop" ];
          "video/mp2t" = [ "mpv.desktop" ];
          "audio/flac" = [ "mpv.desktop" ];
          "audio/mp4" = [ "mpv.desktop" ];
          "application/x-mpegurl" = [ "mpv.desktop" ];
          "video/vnd.mpegurl" = [ "mpv.desktop" ];
          "application/vnd.apple.mpegurl" = [ "mpv.desktop" ];
          "audio/x-pn-au" = [ "mpv.desktop" ];
          "video/3gp" = [ "mpv.desktop" ];
          "video/3gpp" = [ "mpv.desktop" ];
          "video/3gpp2" = [ "mpv.desktop" ];
          "audio/3gpp" = [ "mpv.desktop" ];
          "audio/3gpp2" = [ "mpv.desktop" ];
          "video/dv" = [ "mpv.desktop" ];
          "audio/dv" = [ "mpv.desktop" ];
          "audio/opus" = [ "mpv.desktop" ];
          "audio/vnd.dts" = [ "mpv.desktop" ];
          "audio/vnd.dts.hd" = [ "mpv.desktop" ];
          "audio/x-adpcm" = [ "mpv.desktop" ];
          "application/x-cue" = [ "mpv.desktop" ];
          "audio/m3u" = [ "mpv.desktop" ];
        };
      };
    };
  };
}
