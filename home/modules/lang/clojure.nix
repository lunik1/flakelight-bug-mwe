{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ babashka joker leiningen visualvm ];
}
