{ config, lib, pkgs, ... }:

let cfg = config.lunik1.lang.rust;
in {
  options.lunik1.lang.rust.enable = lib.mkEnableOption "Rust";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ rustup rust-analyzer ];
  };
}
