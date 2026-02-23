# Settings for WSL systems

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.wsl;
in
{
  options.lunik1.home.wsl.enable = lib.mkEnableOption "settings for WSL systems";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        wsl-open
      ];
      sessionVariables = {
        LIBGL_ALWAYS_INDIRECT = 1;
        LIBGL_ALWAYS_SOFTWARE = "true";
      };
    };
    programs.zsh = {
      shellAliases = {
        open = "wsl-open";
      };

      loginExtra = ''
        ${lib.getExe pkgs.setxkbmap} -option compose:ralt &> /dev/null
      '';

      # avoid WSLg: pretty buggy in my experience and windows don't integrate well
      # can't disable it entirely as it breaks docker integration
      envExtra = ''
        export DISPLAY=$(${lib.getExe pkgs.busybox} ip route | ${lib.getExe pkgs.busybox} awk '/default/ {print $3}'):0.0
        export GDK_BACKEND=x11
        export QT_QPA_PLATFORM=xcb
        export SDL_VIDEODRIVER=x11
        # export XDG_RUNTIME_DIR=/tmp/no-wslg

        unset PULSE_SERVER
        unset WAYLAND_DISPLAY
      '';
    };
  };
}
