{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.music;
in
{
  options.lunik1.home.music.enable = lib.mkEnableOption "music";

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        feishin
        playerctl
        spotify
      ]
      ++ lib.optional config.lunik1.home.gui.enable spotify;
    programs = {
      ncmpcpp = {
        enable = true;
        package = pkgs.ncmpcpp.override { visualizerSupport = true; };
      };
    };
    services = {
      mpd = {
        enable = true;
        network.startWhenNeeded = true;
        extraConfig = ''
          audio_output {
            type            "pipewire"
            name            "Pipewire Sound Server"
          }

          audio_output {
            type            "fifo"
            name            "my_fifo"
            path            "/tmp/mpd.fifo"
            format          "44100:16:2"
          }'';
      };
      mpdris2.enable = true;
      playerctld.enable = true;
    };

    # TODO add Waybar config
  };
}
