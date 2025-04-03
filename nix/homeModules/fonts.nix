{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.fonts;
in
{
  options.lunik1.home.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        font-awesome
        julia-mono
        material-design-icons
        montserrat
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        sarasa-gothic
        source-code-pro
        source-sans-pro
        source-serif-pro

        lunik1-nur.myosevka.mono
        lunik1-nur.myosevka.aile
        lunik1-nur.myosevka.etoile
        lunik1-nur.myosevka.proportional
      ];

      activation = lib.optionalAttrs config.lunik1.home.non-nixos.enable {
        updateFontCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${lib.getExe' pkgs.fontconfig "fc-cache"}
        '';
      };
    };

    fonts.fontconfig.enable = true;
  };
}
