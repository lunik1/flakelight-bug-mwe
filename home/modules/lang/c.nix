{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.c;
in {
  options.lunik1.home.lang.c.enable = lib.mkEnableOption "C/C++";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ccls
      # clang # collides with gcc
      clang-tools
      gcc
    ];
  };
}
