# For systems with sound

{ config, lib, ... }:

let
  cfg = config.lunik1.system.sound;
in
{
  options.lunik1.system.sound.enable = lib.mkEnableOption "sound";

  config = lib.mkIf cfg.enable {
    sound = {
      enable = true;
      mediaKeys.enable = true;
    };
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
