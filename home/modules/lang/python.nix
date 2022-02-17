{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.python;
in {
  options.lunik1.home.lang.python.enable = lib.mkEnableOption "Python";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [ (python3.withPackages (ps: with ps; [ black poetry ])) ];
  };
}
