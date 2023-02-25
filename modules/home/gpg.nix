{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.gpg;
in {
  options.lunik1.home.gpg.enable = lib.mkEnableOption "gpg";

  config = lib.mkIf cfg.enable {
    home.sessionVariables.GPG_TTY = "$(tty)";

    programs = {
      git.signing = {
        key = "0x9F1451AC2559C602";
        signByDefault = true;
      };
      gpg = {
        enable = true;
        settings = {
          keyserver = "hkps://keys.openpgp.org";
          keyserver-options = "no-honor-keyserver-url";
        };
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
      pinentryFlavor = if config.lunik1.home.gui.enable then "gtk2" else "tty";
    };
  };
}
