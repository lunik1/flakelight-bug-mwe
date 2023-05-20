{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.sh;
in {
  options.lunik1.home.lang.sh.enable = lib.mkEnableOption "Shell";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      shellcheck
      shfmt
      nodePackages_latest.bash-language-server
    ];
  };
}
