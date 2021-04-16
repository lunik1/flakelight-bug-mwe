{ config, lib, pkgs, ... }:

let gruvbox = import ../resources/colourschemes/gruvbox.nix;
in {
  home = {
    packages = with pkgs; [
      bitwarden
      bleachbit
      connman-gtk
      discord
      element-desktop
      gnome3.gucharmap
      hunspellDicts.en-gb-ise # needed for libreoffice
      libreoffice-fresh # TODO languagetool
      opera
      pavucontrol
      plex-media-player
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
    kitty = {
      enable = true;
      font = {
        name = "Myosevka";
        package = pkgs.myosevka;
      };
      settings = rec {
        font_size = "13.0";
        cursor_blink_interval = "0.5";
        cursor_stop_blinking_after = 15;
        focus_follows_mouse = true;
        enable_audio_bell = false;
        remember_window_size = false;
        force_ltr = "true";
        disable_ligatures = "always";
        symbol_map = "U+F0000-U+F0000 Material Design Icons";
        touch_scroll_multiplier = 3;
        mouse_hide_wait = 0;
        input_delay = 1;

        # Colors
        foreground = gruvbox.dark.fg;
        background = gruvbox.dark.bg;
        color0 = gruvbox.dark.black.normal;
        color1 = gruvbox.dark.red.normal;
        color2 = gruvbox.dark.green.normal;
        color3 = gruvbox.dark.yellow.normal;
        color4 = gruvbox.dark.blue.normal;
        color5 = gruvbox.dark.purple.normal;
        color6 = gruvbox.dark.cyan.normal;
        color7 = gruvbox.dark.white.normal;
        color8 = gruvbox.dark.black.bright;
        color9 = gruvbox.dark.red.bright;
        color10 = gruvbox.dark.green.bright;
        color11 = gruvbox.dark.yellow.bright;
        color12 = gruvbox.dark.blue.bright;
        color13 = gruvbox.dark.purple.bright;
        color14 = gruvbox.dark.cyan.bright;
        color15 = gruvbox.dark.white.bright;
        selection_foreground = background;
        selection_background = foreground;
        url_color = gruvbox.dark.orange.normal;
        cursor = foreground;
      };
      keybindings = {
        # Clipboard
        "kitty_mod+v" = "paste_from_clipboard";
        "kitty_mod+s" = "paste_from_selection";
        "kitty_mod+c" = "copy_to_clipboard";
        "shift+insert" = "paste_from_selection";
        "kitty_mod+o" = "pass_selection_to_program";
        # Scrolling
        "kitty_mod+up" = "scroll_line_up";
        "kitty_mod+down" = "scroll_line_down";
        "kitty_mod+k" = "scroll_line_up";
        "kitty_mod+j" = "scroll_line_down";
        "ctrl+s whift+page_up" = "scroll_page_up";
        "kitty_mod+page_down" = "scroll_page_down";
        "kitty_mod+home" = "scroll_home";
        "kitty_mod+end" = "scroll_end";
        "kitty_mod+h" = "show_scrollback";
        # Window management (diabled)
        "kitty_mod+enter" = "no_op";
        "kitty_mod+n" = "new_os_window";
        "kitty_mod+w" = "no_op";
        "kitty_mod+]" = "no_op";
        "kitty_mod+[" = "no_op";
        "kitty_mod+f" = "no_op";
        "kitty_mod+b" = "no_op";
        "kitty_mod+`" = "no_op";
        "kitty_mod+1" = "no_op";
        "kitty_mod+2" = "no_op";
        "kitty_mod+3" = "no_op";
        "kitty_mod+4" = "no_op";
        "kitty_mod+5" = "no_op";
        "kitty_mod+6" = "no_op";
        "kitty_mod+7" = "no_op";
        "kitty_mod+8" = "no_op";
        "kitty_mod+9" = "no_op";
        "kitty_mod+0" = "no_op";
        # Tab management (disabled)
        "kitty_mod+right" = "no_op";
        "kitty_mod+left" = "no_op";
        "kitty_mod+t" = "no_op";
        "kitty_mod+q" = "no_op";
        "kitty_mod+l" = "no_op";
        "kitty_mod+." = "no_op";
        "kitty_mod+," = "no_op";
        # Misc.
        "kitty_mod+equal" = "change_font_size all +0.5";
        "kitty_mod+minus" = "change_font_size all -0.5";
        "kitty_mod+backspace" = "change_font_size all 0";
        "kitty_mod+f11" = "no_op";
        "kitty_mod+f10" = "no_op";
        "kitty_mod+u" = "input_unicode_character";
      };
    };
    zathura.enable = true;
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.myosevka-aile;
      name = "Myosevka Aile 11";
    };
    iconTheme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
    theme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
    gtk2.extraConfig = ''
      gtk-error-bell = 0
    '';
    gtk3.extraConfig.gtk-error-bell = 0;
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "opera.desktop" ];
        "text/xhtml_xml" = [ "opera.desktop" ];
        "application/x-opera-download" = [ "opera.desktop" ];
        "x-scheme-handler/about" = [ "opera.desktop" ];
        "x-scheme-handler/http" = [ "opera.desktop" ];
        "x-scheme-handler/https" = [ "opera.desktop" ];
        "x-scheme-handler/unknown" = [ "opera.desktop" ];

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
        "application/x-fictionbook" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
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
        "application/vnd.oasis.opendocument.text-master" = [ "writer.desktop" ];
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
}
