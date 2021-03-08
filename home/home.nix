{ pkgs, ... }:

{
  home.packages = with pkgs; [
    duf
    ranger
    teams
  ];

  home.stateVersion = "20.09";
}
