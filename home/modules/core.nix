# # CLI tools installed by default on NixOS

{ pkgs, config, lib, ... }:

{
  home.packages = with pkgs; [
    # Core utils (installed by defult on NixOS)
    acl
    bashInteractive
    bzip2
    coreutils-full
    cpio
    curl
    diffutils
    findutils
    gawk
    getconf
    getent
    gnugrep
    gnupatch
    gnused
    gnutar
    gzip
    less
    libcap
    mkpasswd
    nano
    netcat
    procps
    su
    time
    util-linux
    which
    xz
    zstd

    nixFlakes
  ];
}
