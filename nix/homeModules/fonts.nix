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
    home.packages = with pkgs; [
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

      myosevka-bin
    ];

    fonts.fontconfig.enable = true;
  };
}
