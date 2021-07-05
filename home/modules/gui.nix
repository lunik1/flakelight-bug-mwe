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
        connman-gtk
        discord
        element-desktop
        gimp
        gnome3.gucharmap
        hunspellDicts.en-gb-ise # needed for libreoffice
        krita
        libreoffice-fresh # TODO languagetool
        # libsixel
        opera
        pavucontrol
        qdirstat
        skypeforlinux
        teams
        thunderbird
        xdg_utils
        xfce.thunar

        myosevka-aile
      ];

      sessionVariables = { MOZ_WEBRENDER = "1"; };
    };

    programs = {
      feh.enable = true;
      firefox = {
        enable = true;
        package = pkgs.firefox-wayland;
      };
      foot = {
        enable = true;
        server.enable = true;
        settings = {
          main = {
            # term = "foot-direct"; # breaks zsh syntax highlighting
            font = "Myosevka:size=6.8";
          };
          scrollback.lines = 5000;
          cursor.blink = true;
          colors = builtins.mapAttrs (_: lib.removePrefix "#") {
            foreground = gruvbox.dark.fg;
            background = gruvbox.dark.bg;
            regular0 = gruvbox.dark.black.normal;
            regular1 = gruvbox.dark.red.normal;
            regular2 = gruvbox.dark.green.normal;
            regular3 = gruvbox.dark.yellow.normal;
            regular4 = gruvbox.dark.blue.normal;
            regular5 = gruvbox.dark.purple.normal;
            regular6 = gruvbox.dark.cyan.normal;
            regular7 = gruvbox.dark.white.normal;
            bright0 = gruvbox.dark.black.bright;
            bright1 = gruvbox.dark.red.bright;
            bright2 = gruvbox.dark.green.bright;
            bright3 = gruvbox.dark.yellow.bright;
            bright4 = gruvbox.dark.blue.bright;
            bright5 = gruvbox.dark.purple.bright;
            bright6 = gruvbox.dark.cyan.bright;
            bright7 = gruvbox.dark.white.bright;
            urls = gruvbox.dark.orange.normal;
          };
        };
      };
      zathura = {
        enable = true;
        options = import ../config/zathura/zathura.nix;
      };
    };

    # TODO find/make a gruvbox gtk theme (use oomox?)
    gtk = {
      enable = true;
      font = {
        package = pkgs.myosevka-aile;
        name = "Myosevka Aile 11";
      };
      iconTheme = {
        package = pkgs.qogir-theme;
        name = "Qogir";
      };
      theme = {
        package = pkgs.qogir-icon-theme;
        name = "Qogir";
      };
      gtk2.extraConfig = ''
        gtk-error-bell = 0
      '';
      gtk3.extraConfig.gtk-error-bell = 0;
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style = {
        package = pkgs.arc-kde-theme;
        name = "Arc";
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
          "application/x-opera-download" = [ "opera.desktop" ];

          "x-scheme-handler/msteams" = [ "teams.desktop" ];

          "x-scheme-handler/skype" = [ "skypeforlinux.desktop" ];

          "inode/directory" = [ "thunar.desktop" ];

          "message/rfc822" = [ "thunderbird.desktop" ];
          "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          "x-scheme-handler/news" = [ "thunderbird.desktop" ];
          "x-scheme-handler/nntp" = [ "thunderbird.desktop" ];
          "x-scheme-handler/snews" = [ "thunderbird.desktop" ];

          "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "appliction/oxps" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "application/x-fictionbook" =
            [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "application/x-cbr" = [ "org.pwmt.zathura-cb.desktop" ];
          "application/x-cb7" = [ "org.pwmt.zathura-cb.desktop" ];
          "application/x-cbt" = [ "org.pwmt.zathura-cb.desktop" ];
          "image/vnd.djvu" = [ "org.pwmt.zathura-djvu.desktop" ];
          "image/vnd.djvu+multipage" = [ "org.pwmt.zathura-djvu.desktop" ];
          "application/postscript" = [ "org.pwmt.zathura-ps.desktop" ];
          "application/eps" = [ "org.pwmt.zathura-ps.desktop" ];
          "application/x-eps" = [ "org.pwmt.zathura-ps.desktop" ];
          "image/eps" = [ "org.pwmt.zathura-ps.desktop" ];
          "image/x-eps" = [ "org.pwmt.zathura-ps.desktop" ];

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
