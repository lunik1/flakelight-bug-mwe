{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.games;
in {
  options.lunik1.home.games = {
    steam.enable = lib.mkEnableOption "Enable Steam?";
    emu.enable = lib.mkEnableOption "Enable emulation? (RetroArch)";
    cli.enable =
      lib.mkEnableOption "Add games that can be played on a terminal";
    freeciv.enable = lib.mkEnableOption "Enable Freeciv";
    df.enable = lib.mkEnableOption "Enable Dwarf Fortress";
    minecraft.enable = lib.mkEnableOption "Enable Minecraft";
    openrct2.enable = lib.mkEnableOption "Enable Roller Coaster Tycoon 2";
    wesnoth.enable = lib.mkEnableOption "Enable The Battle for Wesnoth";
    dcss.enable = lib.mkEnableOption "Enable Dungeon Crawl Stone Soup";
  };

  config.home.packages = with pkgs;
    ([ ] ++ lib.optionals cfg.steam.enable [ steam steam-run ]
      ++ lib.optional cfg.emu.enable (retroarch.override {
      cores = [
        libretro.beetle-psx
        libretro.bsnes-mercury
        libretro.mesen
        libretro.mgba
        libretro.nestopia
        libretro.sameboy
        libretro.thepowdertoy
      ];
    }) ++ lib.optionals cfg.cli.enable [ crawl nethack ]
      ++ lib.optional cfg.freeciv.enable (if config.lunik1.home.kde.enable then freeciv_qt else freeciv_gtk)
      ++ lib.optional cfg.df.enable dwarf-fortress-packages.dwarf-fortress-full
      ++ lib.optional cfg.minecraft.enable (if config.lunik1.home.kde.enable then prismlauncher-qt5 else prismlauncher)
      ++ lib.optional cfg.openrct2.enable openrct2
      ++ lib.optional cfg.wesnoth.enable wesnoth
      ++ lib.optionals cfg.dcss.enable [ crawl crawlTiles ]);
}
