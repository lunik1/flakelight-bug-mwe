{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ black poetry python-language-server python3 ];
}
