# Settings for WSL systems

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.wsl;
in {
  options.lunik1.home.wsl.enable =
    lib.mkEnableOption "settings for WSL systems";

  config = lib.mkIf cfg.enable {
    home.sessionVariables.LIBGL_ALWAYS_INDIRECT = 1;

    programs.zsh.envExtra = lib.mkIf config.programs.zsh.enable ''
      export DISPLAY=$(${pkgs.gawk}/bin/awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
    '';
  };
}
