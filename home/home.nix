{ pkgs, ... }:

{
  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    bitwarden
    borgbackup
    chezmoi
    cmake
    cmst
    discord
    duf
    element-desktop
    fd
    gnome3.simple-scan
    hplip
    libarchive
    libreoffice-fresh
    magic-wormhole
    megasync
    ncdu
    nodejs
    opera
    pavucontrol
    plex-media-player
    psmisc
    qdirstat
    ranger
    ripgrep
    ripgrep-all
    rsync
    shfmt
    skypeforlinux
    system-config-printer
    tealdeer
    teams
    thunderbird
    yarn

    # Games
    crawl
    crawlTiles
    # dwarf-fortress-packages.dwarf-fortress-full
    # freeciv
    # freeciv_gtk
    # freeciv_qt qt5.qtwayland
    openrct2
    # wesnoth

    # Dev
    # C/C++
    ccls
    # clang # collides with gcc
    clang-tools
    gcc

    # Nix
    nixFlakes
    nixfmt
    nixpkgs-fmt

    # Python
    poetry
    python-language-server

    # Clojure
    joker
    leiningen

    # Misc
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs

    # Linters
    nixpkgs-fmt
    nodePackages.write-good
    proselint
    python37Packages.yamllint
    vale
    vim-vint
  ];

  programs = {
    aria2.enable = true;
    bat = {
      enable = true;
      config = { theme = "gruvbox-dark"; };
    };
    feh.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
    zathura.enable = true;
  };

  home.stateVersion = "20.09";
}
