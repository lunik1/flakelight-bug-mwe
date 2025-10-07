{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.gui;
in
{
  options.lunik1.home.gui.enable = lib.mkEnableOption "GUI programs";

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables.NIXOS_OZONE_WL = if pkgs.stdenv.isLinux then "1" else "";
      packages =
        with pkgs;
        [
          bleachbit
          vesktop
          lunik1-nur.myosevka.aile
        ]
        ++ lib.optionals stdenv.isLinux [
          bitwarden
          floorp-bin
          gucharmap
          hunspellDicts.en-gb-ise # needed for libreoffice
          krita
          # jellyfin-media-player  # insecure (depends on qtwebengine)
          pinta
          qdirstat
          signal-desktop
          thunderbird
          xdg-utils

          lunik1-nur.amazing-marvin
          lunik1-nur.bach
        ]
        ++ (
          if config.lunik1.home.kde.enable then
            [
              libreoffice-qt-fresh
              lxqt.pavucontrol-qt
              (ventoy.override {
                withQt5 = true;
                defaultGuiType = "qt5";
              })
            ]
          else if pkgs.stdenv.isLinux then
            [
              libreoffice-fresh
              pwvucontrol
              (ventoy.override {
                withGtk3 = true;
                defaultGuiType = "gtk3";
              })
            ]
          else
            [ ]
        );

      sessionVariables = {
        MOZ_WEBRENDER = "1";
      };
    };

    programs = {
      feh.enable = pkgs.stdenv.isLinux;
      firefox = {
        enable = pkgs.stdenv.isLinux;
        package = null;
        profiles.corin = {
          isDefault = true;
          settings = {
            "svg.context-properties.content.enabled" = true;

            # Disable pinch to zoom
            "apz.gtk.touchpad_pinch.enabled" = false;

            # Save session every 60s (in stead of 15)
            "browser.sessionstore.interval" = 60000;

            # Use system dpi
            "layout.css.dpi" = 0;

            # Force enable hardware video decoding
            "media.hardware-video-decoding.enabled" = true;
            "media.hardware-video-decoding.foce-enabled" = true;

            # No fullscreen warning
            "full-screen-api.warning.timeout" = 0;

            # Opt out of studies
            "app.shield.optoutstudies.enabed" = false;

            # Use forbidden pixel-saving methods
            "browser.compactmode.show" = true;
            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

            # Strict tracking protection
            "browser.contentblocking.category" = "strict";

            # Send DNT header
            "privacy.donottrackheader.enabled" = true;

            # Separate search bar
            "browser.search.widget.inNavBar" = true;

            # HTTPS only mode
            "dom.security.https_only_mode" = true;

            # No desktop notifications
            "permissions.default.desktop-notification" = 2;

            # No VR
            "permissions.default.xr" = 2;

            # Warn on quit
            "browser.sessionstore.warnOnQuit" = true;

            # UK
            "browser.search.region" = "GB";

            # Search with DDG
            "browser.urlbar.placeholderName" = "DuckDuckGo";

            # Disable pocket
            "extensions.pocket.enabled" = false;

            # Use light themes on websites
            "layout.css.prefers-color-scheme.content-override" = 1;
          };
        };
      };
      zathura = {
        enable = true;
        options = import ../../config/zathura/zathura.nix;
      };
    };

    services.playerctld.enable = pkgs.stdenv.isLinux;

    xdg = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;

      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ "floorp.desktop" ];
          "text/xhtml_xml" = [ "floorp.desktop" ];
          "x-scheme-handler/about" = [ "floorp.desktop" ];
          "x-scheme-handler/http" = [ "floorp.desktop" ];
          "x-scheme-handler/https" = [ "floorp.desktop" ];
          "x-scheme-handler/unknown" = [ "floorp.desktop" ];

          "x-scheme-handler/msteams" = [ "teams.desktop" ];

          "x-scheme-handler/skype" = [ "skypeforlinux.desktop" ];

          "message/rfc822" = [ "thunderbird.desktop" ];
          "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          "x-scheme-handler/news" = [ "thunderbird.desktop" ];
          "x-scheme-handler/nntp" = [ "thunderbird.desktop" ];
          "x-scheme-handler/snews" = [ "thunderbird.desktop" ];

          "application/pdf" = [ "zathura.desktop" ];

          # Libreoffice
          "application/vnd.openofficeorg.extension" = [ "startcenter.desktop" ];
          "x-scheme-handler/vnd.libreoffice.cmis" = [ "startcenter.desktop" ];

          "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.spreadsheet-template" = [ "calc.desktop" ];
          "application/vnd.sun.xml.calc" = [ "calc.desktop" ];
          "application/vnd.sun.xml.calc.template" = [ "calc.desktop" ];
          "application/msexcel" = [ "calc.desktop" ];
          "application/vnd.ms-excel" = [ "calc.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
          "application/vnd.ms-excel.sheet.macroEnabled.12" = [ "calc.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = [ "calc.desktop" ];
          "application/vnd.ms-excel.template.macroEnabled.12" = [ "calc.desktop" ];
          "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = [ "calc.desktop" ];
          "text/csv" = [ "calc.desktop" ];
          "application/x-dbf" = [ "calc.desktop" ];
          "text/spreadsheet" = [ "calc.desktop" ];
          "application/csv" = [ "calc.desktop" ];
          "application/excel" = [ "calc.desktop" ];
          "application/tab-separated-values" = [ "calc.desktop" ];
          "application/vnd.lotus-1-2-3" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.chart" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.chart-template" = [ "calc.desktop" ];
          "application/x-dbase" = [ "calc.desktop" ];
          "application/x-dos_ms_excel" = [ "calc.desktop" ];
          "application/x-excel" = [ "calc.desktop" ];
          "application/x-msexcel" = [ "calc.desktop" ];
          "application/x-ms-excel" = [ "calc.desktop" ];
          "application/x-quattropro" = [ "calc.desktop" ];
          "application/x-123" = [ "calc.desktop" ];
          "text/comma-separated-values" = [ "calc.desktop" ];
          "text/tab-separated-values" = [ "calc.desktop" ];
          "text/x-comma-separated-values" = [ "calc.desktop" ];
          "text/x-csv" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.spreadsheet-flat-xml" = [ "calc.desktop" ];
          "application/x-iwork-numbers-sffnumbers" = [ "calc.desktop" ];
          "application/x-starcalc" = [ "calc.desktop" ];

          "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
          "application/vnd.oasis.opendocument.presentation-template" = [ "impress.desktop" ];
          "application/vnd.sun.xml.impress" = [ "impress.desktop" ];
          "application/vnd.sun.xml.impress.template" = [ "impress.desktop" ];
          "application/mspowerpoint" = [ "impress.desktop" ];
          "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
          "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.template" = [ "impress.desktop" ];
          "application/vnd.ms-powerpoint.template.macroEnabled.12" = [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.slide" = [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = [ "impress.desktop" ];
          "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" = [ "impress.desktop" ];
          "application/vnd.oasis.opendocument.presentation-flat-xml" = [ "impress.desktop" ];
          "application/x-iwork-keynote-sffkey" = [ "impress.desktop" ];

          "application/vnd.oasis.opendocument.formula" = [ "math.desktop" ];
          "application/vnd.sun.xml.math" = [ "math.desktop" ];
          "application/vnd.oasis.opendocument.formula-template" = [ "math.desktop" ];
          "text/mathml" = [ "math.desktop" ];
          "application/mathml+xml" = [ "math.desktop" ];

          "application/vnd.oasis.opendocument.graphics" = [ "draw.desktop" ];
          "application/vnd.oasis.opendocument.graphics-flat-xml" = [ "draw.desktop" ];
          "application/vnd.oasis.opendocument.graphics-template" = [ "draw.desktop" ];
          "application/vnd.sun.xml.draw" = [ "draw.desktop" ];
          "application/vnd.sun.xml.draw.template" = [ "draw.desktop" ];
          "application/vnd.visio" = [ "draw.desktop" ];
          "application/x-wpg" = [ "draw.desktop" ];
          "application/vnd.corel-draw" = [ "draw.desktop" ];
          "application/vnd.ms-publisher" = [ "draw.desktop" ];
          "image/x-freehand" = [ "draw.desktop" ];
          "application/x-pagemaker" = [ "draw.desktop" ];
          "application/x-stardraw" = [ "draw.desktop" ];
          "image/x-emf" = [ "draw.desktop" ];
          "image/x-wmf" = [ "draw.desktop" ];

          "application/vnd.oasis.opendocument.database" = [ "base.desktop" ];
          "application/vnd.sun.xml.base" = [ "base.desktop" ];

          "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-template" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-web" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-master" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-master-template" = [ "writer.desktop" ];
          "application/vnd.sun.xml.writer" = [ "writer.desktop" ];
          "application/vnd.sun.xml.writer.template" = [ "writer.desktop" ];
          "application/vnd.sun.xml.writer.global" = [ "writer.desktop" ];
          "application/msword" = [ "writer.desktop" ];
          "application/vnd.ms-word" = [ "writer.desktop" ];
          "application/x-doc" = [ "writer.desktop" ];
          "application/x-hwp" = [ "writer.desktop" ];
          "application/rtf" = [ "writer.desktop" ];
          "text/rtf" = [ "writer.desktop" ];
          "application/vnd.wordperfect" = [ "writer.desktop" ];
          "application/wordperfect" = [ "writer.desktop" ];
          "application/vnd.lotus-wordpro" = [ "writer.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
          "application/vnd.ms-word.document.macroEnabled.12" = [ "writer.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = [ "writer.desktop" ];
          "application/vnd.ms-word.template.macroEnabled.12" = [ "writer.desktop" ];
          "application/vnd.ms-works" = [ "writer.desktop" ];
          "application/vnd.stardivision.writer-global" = [ "writer.desktop" ];
          "application/x-extension-txt" = [ "writer.desktop" ];
          "application/x-t602" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-flat-xml" = [ "writer.desktop" ];
          "application/x-fictionbook+xml" = [ "writer.desktop" ];
          "application/macwriteii" = [ "writer.desktop" ];
          "application/x-aportisdoc" = [ "writer.desktop" ];
          "application/prs.plucker" = [ "writer.desktop" ];
          "application/vnd.palm" = [ "writer.desktop" ];
          "application/clarisworks" = [ "writer.desktop" ];
          "application/x-sony-bbeb" = [ "writer.desktop" ];
          "application/x-abiword" = [ "writer.desktop" ];
          "application/x-iwork-pages-sffpages" = [ "writer.desktop" ];
          "application/x-mswrite" = [ "writer.desktop" ];
          "application/x-starwriter" = [ "writer.desktop" ];
        };
      };

      terminal-exec = {
        enable = true;
        settings.default = [ "kitty.desktop" ];
      };
    };
  };
}
