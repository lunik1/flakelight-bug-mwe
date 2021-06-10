{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.lang.data;
in {
  options.lunik1.home.lang.data.enable = lib.mkEnableOption "data formats";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Json
      jq
      nodePackages.vscode-json-languageserver-bin

      # YAML
      yamllint
      nodePackages.yaml-language-server
    ];
  };
}
