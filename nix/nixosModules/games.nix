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
    enable = lib.mkEnableOption "games";
    steam.enable = lib.mkEnableOption "steam";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            desiredgov = "performance";
            renice = 5;
            softrealtime = "auto";
          };

          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 1;
            amd_performance_level = "high";
          };
        };
      };

      steam = lib.mkIf cfg.steam.enable {
        enable = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
        gamescopeSession.enable = true;
        localNetworkGameTransfers.openFirewall = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
      };
    };

    users.users.corin.extraGroups = [ "gamemode" ];
  };
}
