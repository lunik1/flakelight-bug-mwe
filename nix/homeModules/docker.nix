{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [ nodePackages_latest.dockerfile-language-server-nodejs ];
}
