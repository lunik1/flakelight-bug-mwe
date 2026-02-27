{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.cli;
in
{
  options.lunik1.home.cli.enable = lib.mkEnableOption "CLI programs";

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = pkgs.lib.lunik1.myTrue;
    };
  };
}
