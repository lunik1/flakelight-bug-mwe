{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.gpg;
in
{
  options.lunik1.home.gpg.enable = lib.mkEnableOption "gpg";

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables.GPG_TTY = "$(tty)";
      file.sshcontrol = {
        text = ''
          83AFE963DC1577DCAB2E51C68CF90C0A55FDA32E
        '';
        target = ".gnupg/sshcontrol";
      };
    };

    programs = {
      git.signing = {
        key = "0x9F1451AC2559C602";
        signByDefault = true;
      };
      gpg = {
        enable = true;
        # homedir = "${config.xdg.dataHome}/gnupg";  # breaks commit signing in emacs
        settings = {
          keyserver = "hkps://keyserver.ubuntu.com";
          keyserver-options = "no-honor-keyserver-url";
        }
        // lib.optionalAttrs (!config.lunik1.home.gui.enable) { pinentry-mode = "loopback"; };
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
      pinentry.package =
        with pkgs;
        if config.lunik1.home.gnome.enable then
          pinentry-gnome3
        else
          (if (!config.lunik1.home.gui.enable) then pinentry-qt else pinentry-tty);
    }
    // lib.optionalAttrs config.lunik1.home.gui.enable {
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };
}
