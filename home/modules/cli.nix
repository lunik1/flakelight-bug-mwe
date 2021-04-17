{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      bat-extras.batgrep
      borgbackup
      bpytop
      chezmoi
      cmake
      duf
      eternal-terminal
      fast-cli
      fd
      ffmpeg-full
      imagemagick
      libarchive
      lrzip
      magic-wormhole
      ncdu
      neofetch
      p7zip
      pandoc
      parallel
      parted
      psmisc
      ranger
      ripgrep
      rmlint
      rsync
      stress-ng
      tealdeer
      unrar
      unzip
      wget
      youtube-dl

      ripgrep-all # heavy dependencies, optional/own module?
    ];

    file = {
      ".zshrc.local" = {
        source = ../config/zsh/.zshrc.local;
        target = ".zshrc.local";
      };
    };

    sessionPath = [ "~/bin" ];
  };

  programs = {
    aria2 = {
      enable = true;
      settings = {
        max-connection-per-server = 4;
        continue = true;
      };
    };
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
        pager = "less -FR";
      };
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = builtins.readFile "${pkgs.LS_COLORS}/LS_COLORS";
    };
    htop = import ../config/htop/htop.nix;
    ssh = import ../config/ssh/config.nix;
    tmux = import ../config/tmux/tmux.nix { tmuxPlugins = pkgs.tmuxPlugins; };
    fzf = rec {
      enable = true;
      enableFishIntegration = false;
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd -H --type directory";
      defaultCommand = "${pkgs.fd}/bin/fd -H -E '.git' --type file";
      fileWidgetCommand = defaultCommand;
    };
    zsh = {
      enable = true;
      enableVteIntegration = true;
      history = { size = 50000; };
      initExtraFirst = ''
        source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
      envExtra = ''
        export PATH=$HOME/bin:$HOME/.cargo/bin/:$PATH
      '';
    };
  };
}
