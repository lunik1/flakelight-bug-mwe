{ config, lib, pkgs, ... }:

let cfg = config.lunik1.lang.sh;
in {
  options.lunik1.lang.sh.enable = lib.mkEnableOption "Shell";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      shellcheck
      shfmt
      nodePackages.bash-language-server
    ];
  };
}
