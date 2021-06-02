{ config, lib, pkgs, ... }:

let cfg = config.lunik1.lang.python;
in {
  options.lunik1.lang.python.enable = lib.mkEnableOption "Python";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ black poetry python-language-server python3 ];
  };
}
