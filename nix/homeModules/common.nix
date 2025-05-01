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

    services.home-manager.autoExpire = {
      enable = true;
      frequency = "weekly";
      timestamp = "-14 days";
    };

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.age-key.txt";
      defaultSopsFile = ../../secrets/user/secrets.yaml;
    };
  };
}
