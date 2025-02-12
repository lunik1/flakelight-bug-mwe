{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.prose;
in
{
  options.lunik1.home.lang.prose.enable = lib.mkEnableOption "prose";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      languagetool
      # nodePackages_latest.write-good
      proselint
      vale
    ];
  };
}
