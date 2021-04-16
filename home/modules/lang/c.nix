{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    ccls
    # clang # collides with gcc
    clang-tools
    gcc
  ];
}
