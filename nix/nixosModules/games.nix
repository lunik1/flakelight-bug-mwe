{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.system.games;
in
{
  options.lunik1.system.games = {
    steam.enable = lib.mkEnableOption "steam";
  };

  config = {
    programs.steam = lib.mkIf cfg.steam.enable {
      enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      gamescopeSession.enable = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
