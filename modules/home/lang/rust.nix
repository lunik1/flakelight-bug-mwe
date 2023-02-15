{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.rust;
in {
  options.lunik1.home.lang.rust.enable = lib.mkEnableOption "Rust";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (lib.setPrio 100 bintools) # prevent collisions with gcc and clang
      cargo
      rust-analyzer
    ];
  };
}
