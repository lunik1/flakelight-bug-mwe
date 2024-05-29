{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.julia;
in
{
  options.lunik1.home.lang.julia.enable = lib.mkEnableOption "Julia";

  config = lib.mkIf cfg.enable { home.packages = with pkgs; [ julia-stable-bin ]; };
}
