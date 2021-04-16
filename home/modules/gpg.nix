{ config, lib, pkgs, ... }:

{
  programs = {
    git.signing = {
      key = "BA3A5886AE6D526E20B457D66A37DF9483188492";
      signByDefault = true;
    };
    gpg = {
      enable = true;
      settings.keyserver = "hkps://keys.openpgp.org";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    extraConfig = "";
  };
}
