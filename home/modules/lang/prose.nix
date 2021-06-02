{ config, lib, pkgs, ... }:

let cfg = config.lunik1.lang.prose;
in {
  options.lunik1.lang.prose.enable = lib.mkEnableOption "prose";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      languagetool
      nodePackages.write-good
      proselint
      vale
    ];
  };
}
