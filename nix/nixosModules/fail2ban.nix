{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.system.fail2ban;
  autheliaInstances = config.services.authelia.instances;
in
{
  options.lunik1.system.fail2ban.enable = lib.mkEnableOption "fail2ban";

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      bantime = "15m";
      maxretry = 10;
      bantime-increment = {
        overalljails = true;
        rndtime = "12m";
        formula = "math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      };
      jails = lib.optionalAttrs (autheliaInstances != { }) {
        authelia = {
          filter = "authelia";
        };
      };
    };

    systemd.tmpfiles.rules = lib.optionals (autheliaInstances != { }) [
      "L+ /etc/fail2ban/filter.d/authelia.conf - - - - ${builtins.toFile "authelia.conf" ''
        [Definition]
        journalmatch = ${
          builtins.concatStringsSep " " (
            map (str: "_SYSTEMD_UNIT=authelia-${str}.service") (builtins.attrNames autheliaInstances)
          )
        }
        failregex = ^.*Unsuccessful (1FA|TOTP|Duo|U2F) authentication attempt by user .*remote_ip"?(:|=)"?<HOST>"?.*$
                    ^.*user not found.*path=/api/reset-password/identity/start remote_ip"?(:|=)"?<HOST>"?.*$
                    ^.*Sending an email to user.*path=/api/.*/start remote_ip"?(:|=)"?<HOST>"?.*$
                    ^.*failed to validate parsed credentials of Authorization header for user .*remote_ip"?(:|=)"?<HOST>"?.*$
        ignoreregex = ^.*level"?(:|=)"?info.*
                      ^.*level"?(:|=)"?warning.*
      ''}"
    ];
  };
}
