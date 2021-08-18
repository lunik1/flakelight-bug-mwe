{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.tex;
in {
  options.lunik1.home.lang.tex.enable = lib.mkEnableOption "TeX";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      svg2tikz
      texlab
      python38Packages.pygments
    ];

    programs = {
      texlive = {
        enable = true;
        extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
      };
    };
  };
}
