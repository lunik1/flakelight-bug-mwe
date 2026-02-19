{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.julia;
in
{
  options.lunik1.home.lang.julia.enable = lib.mkEnableOption "Julia";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ julia ];

    programs.zsh.shellAliases = {
      juliad = "julia --startup-file=no -e 'using DaemonMode; serve()'";
      juliac = "julia --startup-file=no -e 'using DaemonMode; runargs()'";
    };
  };

}
