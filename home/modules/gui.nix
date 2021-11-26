{ config, lib, pkgs, ... }:

let
  gruvbox = import ../resources/colourschemes/gruvbox.nix;
  cfg = config.lunik1.home.gui;
in {
  options.lunik1.home.gui.enable = lib.mkEnableOption "GUI programs";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        bitwarden
        bleachbit
        dbeaver
        discord
        element-desktop
        gimp
        gnome3.gucharmap
        hunspellDicts.en-gb-ise # needed for libreoffice
        krita
        jitsi-meet-electron
        libreoffice-fresh # TODO languagetool
        # libsixel
        pavucontrol
        qdirstat
        skypeforlinux
        teams
        thunderbird
        ungoogled-chromium
        xdg_utils

        myosevka-aile
      ];

      sessionVariables = { MOZ_WEBRENDER = "1"; };

      file.firefox-lepton-icons = {
        source = "${pkgs.firefox-lepton}/icons";
        target = ".mozilla/firefox/corin/chrome/icons";
      };
    };

    programs = {
      feh.enable = true;
      firefox = {
        enable = true;
        package = pkgs.firefox-bin.override {
          cfg = {
            enablePlasmaBrowserIntegration = config.lunik1.home.kde.enable;
          };
        };
        profiles.corin = {
          isDefault = true;
          extraConfig = builtins.readFile "${pkgs.firefox-lepton}/user.js";
          userChrome =
            builtins.readFile "${pkgs.firefox-lepton}/userChrome.css";
          userContent =
            builtins.readFile "${pkgs.firefox-lepton}/userContent.css";
          settings = {
            "svg.context-properties.content.enabled" = true;

            # Disk cache on RAM
            "browser.cache.disk.parent_directory" = "/run/user/1000/firefox";

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
          };
        };
      };
    };

    xdg = {
      enable = true;
      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ "firefox.desktop" ];
          "text/xhtml_xml" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];

          "x-scheme-handler/msteams" = [ "teams.desktop" ];

          "x-scheme-handler/skype" = [ "skypeforlinux.desktop" ];

          "message/rfc822" = [ "thunderbird.desktop" ];
          "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          "x-scheme-handler/news" = [ "thunderbird.desktop" ];
          "x-scheme-handler/nntp" = [ "thunderbird.desktop" ];
          "x-scheme-handler/snews" = [ "thunderbird.desktop" ];

          # Libreoffice
          "application/vnd.openofficeorg.extension" = [ "startcenter.desktop" ];
          "x-scheme-handler/vnd.libreoffice.cmis" = [ "startcenter.desktop" ];

          "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.spreadsheet-template" =
            [ "calc.desktop" ];
          "application/vnd.sun.xml.calc" = [ "calc.desktop" ];
          "application/vnd.sun.xml.calc.template" = [ "calc.desktop" ];
          "application/msexcel" = [ "calc.desktop" ];
          "application/vnd.ms-excel" = [ "calc.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
            [ "calc.desktop" ];
          "application/vnd.ms-excel.sheet.macroEnabled.12" = [ "calc.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template" =
            [ "calc.desktop" ];
          "application/vnd.ms-excel.template.macroEnabled.12" =
            [ "calc.desktop" ];
          "application/vnd.ms-excel.sheet.binary.macroEnabled.12" =
            [ "calc.desktop" ];
          "text/csv" = [ "calc.desktop" ];
          "application/x-dbf" = [ "calc.desktop" ];
          "text/spreadsheet" = [ "calc.desktop" ];
          "application/csv" = [ "calc.desktop" ];
          "application/excel" = [ "calc.desktop" ];
          "application/tab-separated-values" = [ "calc.desktop" ];
          "application/vnd.lotus-1-2-3" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.chart" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.chart-template" =
            [ "calc.desktop" ];
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
          "application/vnd.oasis.opendocument.spreadsheet-flat-xml" =
            [ "calc.desktop" ];
          "application/x-iwork-numbers-sffnumbers" = [ "calc.desktop" ];
          "application/x-starcalc" = [ "calc.desktop" ];

          "application/vnd.oasis.opendocument.presentation" =
            [ "impress.desktop" ];
          "application/vnd.oasis.opendocument.presentation-template" =
            [ "impress.desktop" ];
          "application/vnd.sun.xml.impress" = [ "impress.desktop" ];
          "application/vnd.sun.xml.impress.template" = [ "impress.desktop" ];
          "application/mspowerpoint" = [ "impress.desktop" ];
          "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
            [ "impress.desktop" ];
          "application/vnd.ms-powerpoint.presentation.macroEnabled.12" =
            [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.template" =
            [ "impress.desktop" ];
          "application/vnd.ms-powerpoint.template.macroEnabled.12" =
            [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.slide" =
            [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
            [ "impress.desktop" ];
          "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" =
            [ "impress.desktop" ];
          "application/vnd.oasis.opendocument.presentation-flat-xml" =
            [ "impress.desktop" ];
          "application/x-iwork-keynote-sffkey" = [ "impress.desktop" ];

          "application/vnd.oasis.opendocument.formula" = [ "math.desktop" ];
          "application/vnd.sun.xml.math" = [ "math.desktop" ];
          "application/vnd.oasis.opendocument.formula-template" =
            [ "math.desktop" ];
          "text/mathml" = [ "math.desktop" ];
          "application/mathml+xml" = [ "math.desktop" ];

          "application/vnd.oasis.opendocument.graphics" = [ "draw.desktop" ];
          "application/vnd.oasis.opendocument.graphics-flat-xml" =
            [ "draw.desktop" ];
          "application/vnd.oasis.opendocument.graphics-template" =
            [ "draw.desktop" ];
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
          "application/vnd.oasis.opendocument.text-template" =
            [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-web" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-master" =
            [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-master-template" =
            [ "writer.desktop" ];
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
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
            [ "writer.desktop" ];
          "application/vnd.ms-word.document.macroEnabled.12" =
            [ "writer.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template" =
            [ "writer.desktop" ];
          "application/vnd.ms-word.template.macroEnabled.12" =
            [ "writer.desktop" ];
          "application/vnd.ms-works" = [ "writer.desktop" ];
          "application/vnd.stardivision.writer-global" = [ "writer.desktop" ];
          "application/x-extension-txt" = [ "writer.desktop" ];
          "application/x-t602" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-flat-xml" =
            [ "writer.desktop" ];
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
    };
  };
}
