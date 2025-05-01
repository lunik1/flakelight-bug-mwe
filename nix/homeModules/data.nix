{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.lang.data;
in
{
  options.lunik1.home.lang.data.enable = lib.mkEnableOption "data formats";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Json
      nodePackages_latest.vscode-json-languageserver

      # YAML
      dyff
      yamllint
      yaml-language-server

      # TOML
      taplo

      # csv
      xan
    ];

    programs.jq.enable = true;
  };
}
