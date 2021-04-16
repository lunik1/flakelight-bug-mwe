{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ nodePackages.dockerfile-language-server-nodejs ];
}
