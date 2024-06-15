{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.rust;
in
{
  options.lunik1.home.lang.rust.enable = lib.mkEnableOption "rust";

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = {
        CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
      };

      packages = with pkgs; [ cargo ];
    };

    programs.zsh.envExtra = ''
      export PATH=$HOME/bin:$HOME/.cargo/bin/:$PATH
    '';
  };
}
