{ config, lib, pkgs, ... }:

{
  require = [ ./git.nix lang/viml.nix ];

  home = {
    packages = with pkgs; [
      neovim
      # Needed for plugins
      ripgrep
      fd
      yarn
      nodejs
    ];

    sessionVariables.EDITOR = "nvim";
  };

  pam.sessionVariables.EDITOR = "nvim";
}
