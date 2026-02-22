{
  inputs,
  ...
}:

[
  inputs.wbba.overlays.default
  (self: super: { lunik1-nur = import inputs.lunik1-nur { pkgs = super; }; })
  (self: super: { nix-wallpaper = super.inputs'.nix-wallpaper.packages.default; })
  (self: super: { yt-dlp = super.yt-dlp.override { withAlias = true; }; })
  (self: super: {
    neovim = super.neovim.override {
      vimAlias = true;
      viAlias = true;
    };
  })
  (import ./gruvbox.nix)
]
