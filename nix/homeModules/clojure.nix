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
        clojure
        rlwrap
      ];
    };

    programs.zsh.shellAliases = {
      rr = ''clojure -Sdeps "{:deps {com.bhauman/rebel-readline {:mvn/version \"[0,)\"}}}" -M -m rebel-readline.main'';
      rbb = "rlwrap bb";
    };
  };
}
