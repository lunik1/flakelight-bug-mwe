{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.games;
in
{
  options.lunik1.home.games = {
    saves.enable = lib.mkEnableOption "tools to manage game saves";
    emu.enable = lib.mkEnableOption "emulation";
    cli.enable = lib.mkEnableOption "terminal games";
    freeciv.enable = lib.mkEnableOption "Freeciv";
    df.enable = lib.mkEnableOption "Dwarf Fortress";
    minecraft.enable = lib.mkEnableOption "Minecraft";
    openrct2.enable = lib.mkEnableOption "Roller Coaster Tycoon 2";
    wesnoth.enable = lib.mkEnableOption "The Battle for Wesnoth";
    dcss.enable = lib.mkEnableOption "Dungeon Crawl Stone Soup";
    osu.enable = lib.mkEnableOption "osu";
  };

  config.home.packages =
    with pkgs;
    (
      lib.optionals cfg.saves.enable [
        ludusavi
        rclone
      ]
      ++ lib.optionals cfg.emu.enable [
        ryujinx
        (retroarch.override {
          cores = [
            libretro.beetle-psx
            libretro.bsnes-mercury
            libretro.mesen
            libretro.mgba
            libretro.nestopia
            libretro.sameboy
            libretro.thepowdertoy
          ];
        })
      ]
      ++ lib.optionals cfg.cli.enable [
        crawl
        nethack
      ]
      ++ lib.optional cfg.freeciv.enable (
        if config.lunik1.home.kde.enable then freeciv_qt else freeciv_gtk
      )
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
    ++ lib.optionals cfg.osu.enable [ osu-lazer-bin ];
}
