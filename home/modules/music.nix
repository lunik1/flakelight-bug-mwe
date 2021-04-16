{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ playerctl ];
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
          type            "pulse"
          name            "pulse audio"
        }

        audio_output {
          type            "fifo"
          name            "my_fifo"
          path            "/tmp/mpd.fifo"
          format          "44100:16:2"
        }'';
    };
    mpdris2.enable = true; # TODO: use mpd-mpris instead?
    playerctld.enable = true;
  };

  # TODO add Waybar config
}
