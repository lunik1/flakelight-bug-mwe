# Settings for laptops

{ config, lib, pkgs, ... }:

let cfg = config.lunik1.system.laptop;
in {
  options.lunik1.system.laptop.enable =
    lib.mkEnableOption "laptop settings and programs";

  config = lib.mkIf cfg.enable {
    # Backlight
    programs.light.enable = true;
    services = {
      actkbd = {
        enable = true;
        bindings = [
          {
            keys = [ 225 ]; # XF86MonBrightnessDown
            events = [ "key" ];
            command = "/run/current-system/sw/bin/light -A 10";
          }
          {
            keys = [ 224 ]; # XF86MonBrightnessUp
            events = [ "key" ];
            command = "/run/current-system/sw/bin/light -U 10";
          }
        ];
      };

      # Lid switch
      logind = {
        lidSwitch = "hybrid-sleep";
        lidSwitchExternalPower = "suspend";
      };

      # Power management
      tlp.enable = true;
    };
      environment.systemPackages = with pkgs; [ powertop ];
  };
}
