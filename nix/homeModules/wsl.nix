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
      sessionVariables.LIBGL_ALWAYS_INDIRECT = 1;
    };
    programs.zsh.shellAliases = {
      open = "wsl-open";
    };
  };
}
