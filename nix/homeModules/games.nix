{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  cfg = config.lunik1.home.games;
in
{
  options.lunik1.home.games = {
    cli.enable = lib.mkEnableOption "terminal games";
    dcss.enable = lib.mkEnableOption "Dungeon Crawl Stone Soup";
    df.enable = lib.mkEnableOption "Dwarf Fortress";
    emu.enable = lib.mkEnableOption "emulation";
    freeciv.enable = lib.mkEnableOption "Freeciv";
    itch.enable = lib.mkEnableOption "itch.io";
    minecraft.enable = lib.mkEnableOption "Minecraft";
    openrct2.enable = lib.mkEnableOption "Roller Coaster Tycoon 2";
    osu.enable = lib.mkEnableOption "osu";
    runescape.enable = lib.mkEnableOption "RuneScape 3";
    saves.enable = lib.mkEnableOption "tools to manage game saves";
    wesnoth.enable = lib.mkEnableOption "The Battle for Wesnoth";
  };

  config = {
    nixpkgs.config =
      if osConfig.home-manager.useGlobalPkgs or false then
        null
      else
        {
          permittedInsecurePackages = lib.optionals cfg.runescape.enable [ "openssl-1.1.1w" ];
        };

    home.packages =
      with pkgs;
      (
        lib.optionals cfg.saves.enable [
          ludusavi
          rclone
        ]
        ++ lib.optionals cfg.emu.enable [
          ryujinx
          (retroarch.withCores (cores: [
            libretro.beetle-psx
            libretro.bsnes-mercury
            libretro.mesen
            libretro.mgba
            libretro.nestopia
            libretro.sameboy
            libretro.thepowdertoy
          ]))
        ]
        ++ lib.optionals cfg.cli.enable [
          crawl
          nethack
        ]
        ++ lib.optional cfg.freeciv.enable (
          if config.lunik1.home.kde.enable then freeciv_qt else freeciv_gtk
        )
        ++ lib.optionals cfg.itch.enable [
          itch
        ]
        ++ lib.optional cfg.df.enable dwarf-fortress-packages.dwarf-fortress-full
        ++ lib.optional cfg.minecraft.enable (
          if config.lunik1.home.kde.enable then prismlauncher-qt5 else prismlauncher
        )
        ++ lib.optional cfg.openrct2.enable openrct2
        ++ lib.optional cfg.wesnoth.enable wesnoth
        ++ lib.optionals cfg.dcss.enable [
          crawl
          crawlTiles
        ]
      )
      ++ lib.optionals cfg.osu.enable [ osu-lazer-bin ]
      ++ lib.optionals cfg.runescape.enable [ runescape ];
  };
}
