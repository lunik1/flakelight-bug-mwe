{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.python;
in
{
  options.lunik1.home.lang.python.enable = lib.mkEnableOption "Python";

  config = lib.mkIf cfg.enable {
    programs = {
      ruff = {
        enable = true;
        settings = { };
      };
      ty.enable = true;
      uv.enable = true;
    };
  };
}
