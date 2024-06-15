{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.clojure;
in
{
  options.lunik1.home.lang.clojure.enable = lib.mkEnableOption "clojure";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        babashka
        rlwrap
      ];
    };

    programs.zsh.shellAliases = {
      rbb = "rlwrap bb";
    };
  };
}
