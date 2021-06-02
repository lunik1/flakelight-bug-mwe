{ config, lib, pkgs, ... }:

let cfg = config.lunik1.lang.clojure;
in {
  options.lunik1.lang.clojure.enable = lib.mkEnableOption "Clojure";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ babashka joker leiningen visualvm ];
  };
}
