# Printing and scanning

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.pulp-io;
in {
  options.lunik1.home.pulp-io.enable =
    lib.mkEnableOption "printing and scanning";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ gnome3.simple-scan system-config-printer ];
  };
}
