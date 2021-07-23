{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.python;
in {
  options.lunik1.home.lang.python.enable = lib.mkEnableOption "Python";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ black poetry nodePackages.pyright python3 ];
  };
}
