{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.gpg;
in {
  options.lunik1.home.gpg.enable = lib.mkEnableOption "gpg";

  config = lib.mkIf cfg.enable {
    programs = {
      git.signing = {
        key = "BA3A5886AE6D526E20B457D66A37DF9483188492";
        signByDefault = true;
      };
      gpg = {
        enable = true;
        settings.keyserver = "hkps://keys.openpgp.org";
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
      pinentryFlavor = if config.lunik1.home.gui.enable then "gtk" else "curses";
    };
  };
}
