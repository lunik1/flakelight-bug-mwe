# mpv configuration
# TODO tuned for laptop, needs to be made more configurable

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.mpv;
in {
  options.lunik1.home.mpv.enable = lib.mkEnableOption "mpv";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ playerctl xdg_utils ];

    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        autoload
        mpris
        mpv-playlistmanager
        # thumbnail # performance-intensive
      ];
      config = {
        # Video
        # profile = "gpu-hq";
        vo = "gpu";
        scale = "bicubic_fast";
        cscale = "bicubic_fast";
        dscale = "bilinear";
        # tscale="robidouxsharp";
        scale-antiring = 1;
        cscale-antiring = 1;
        sigmoid-upscaling = "yes";
        # tscale-clamp;
        scaler-resizes-only = "yes";
        dither-depth = "auto";
        dither-size-fruit = 6;
        temporal-dither = "yes";
        gamma-factor = "0.9338";
        deband = "no"; # performance-intensive
        gpu-context = "wayland";
        hwdec = "auto-safe";
        target-prim = "bt.709";
        video-output-levels = "full";
        video-sync = "display-resample";
        # interpolation;
        vd-lavc-skiploopfilter = "bidir";
        sws-scaler = "x";
        screenshot-format = "png";
        screenshot-png-compression = 0;
        screenshot-png-filter = 0;
        screenshot-tag-colorspace = "yes";
        screenshot-high-bit-depth = "yes";
        geometry = "50%:50%";
        autofit = "90%x90%";
        autofit-larger = "90%x90%";
        # vo-vaapi-deint-mode = "bob";
        vd-lavc-threads = 4;

        # Audio
        ao = "pulse";
        audio-channels = "auto";
        volume-max = 200;
        alang = "en,eng,english";
        ad = "lavc:libdcadec";

        # Subtitles
        sub-ass-vsfilter-color-compat = "full";
        sub-ass-force-style = "Kerning=yes";
        demuxer-mkv-subtitle-preroll = "yes";
        slang = "en,eng,english";
        sub-auto = "all";

        # youtube-dl
        ytdl-format =
          "(bestvideo[fps=60][height<=1080]/bestvideo[height<=1080])[vcodec!=vp9]+(bestaudio[acodec=opus]/bestaudio[ext=webm]/bestaudio)/best";
        script-opts="ytdl_hook-ytdl_path=${nixpkgs.yt-dlp}/bin/yt-dlp";

        # Other
        keep-open = "yes";
        idle = "yes";
        script-opts =
          "osc-vidscale=no,osc-layout=bottombar,osc-scalewindowed=2.0,osc-scalefullscreen=2.0,osc-minmousemove=1";
        cache = "auto";
        cache-on-disk = "yes";
        cache-dir = "~/.cache/mpv";
        demuxer-readahead-secs = 20;
        demuxer-max-bytes = "10GiB";
        force-window = "yes";
        no-resume-playback = "";
      };
    };

    xdg = {
      enable = true;
      configFile = {
        # Add scripts distributed with mpv
        "autocrop.lua" = {
          source = "${pkgs.mpv-unwrapped.src.outPath}/TOOLS/lua/autocrop.lua";
          target = "mpv/scripts/autocrop.lua";
        };
        "autodeint.lua" = {
          source = "${pkgs.mpv-unwrapped.src.outPath}/TOOLS/lua/autodeint.lua";
          target = "mpv/scripts/autodeint.lua";
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
