{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Json
    jq
    nodePackages.vscode-json-languageserver-bin

    # YAML
    yamllint
    nodePackages.yaml-language-server
  ];
}
