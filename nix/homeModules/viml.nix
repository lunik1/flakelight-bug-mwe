{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.viml;
in {
  options.lunik1.home.lang.viml.enable = lib.mkEnableOption "Viml";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ vim-vint nodePackages_latest.vim-language-server ];
  };
}
