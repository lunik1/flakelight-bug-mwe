{
  pkgs,
  config,
  lib,
  ...
}:

{
  config = {
    home = {
      sessionVariables.AWK_HASH = "fnv1a";

      file = {
        ".alsoftrc" = {
          text = ''
            hrtf = true
          '';
          target = ".alsoftrc";
        };
      };
    };

    systemd.user.startServices = "sd-switch";

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.age-key.txt";
      defaultSopsFile = ../../secrets/user/secrets.yaml;
    };
  };
}
