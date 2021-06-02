{ config, lib, pkgs, ... }:

let cfg = config.lunik1.lang.tex;
in {
  options.lunik1.lang.tex.enable = lib.mkEnableOption "TeX";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ svg2tikz texlab ];

    programs = {
      texlive = {
        enable = true;
        extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
      };
    };
  };
}
