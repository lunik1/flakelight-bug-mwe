{ config, lib, pkgs, ... }:

let
  gruvbox = import ../resources/colourschemes/gruvbox.nix;
  cfg = config.lunik1.home;
in {
  options.lunik1.home = {
    sway.enable = lib.mkEnableOption "sway";
    waybar = {
      batteryModule = lib.mkEnableOption "Enable the battery module in Waybar";
      bluetoothModule =
        lib.mkEnableOption "Enable the bluetooth module in Waybar";
    };
  };

  config = lib.mkIf cfg.sway.enable {
    home.packages = with pkgs; [
      myosevka
      myosevka-proportional
      material-design-icons
      wev
    ];

    programs.waybar = {
      enable = true;
      package = pkgs.waybar.override { pulseSupport = true; };
      settings = [{
        layer = "bottom";
        position = "bottom";
        # output = [ "eDP-1" ];
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" "idle_inhibitor" "mpd" ];
        modules-right = with config.lunik1.home.waybar;
          ([ "temperature" "cpu" "backlight" ]
            ++ lib.optional batteryModule "battery"
            ++ [ "memory" "disk" "network" ]
            ++ lib.optional bluetoothModule "bluetooth" ++ [
              "pulseaudio"
              "clock"
              # "tray"
            ]);
        modules = {
          "sway/workspaces".numeric-first = true;
          mpd = {
            format =
              "{stateIcon}{repeatIcon}{randomIcon}{singleIcon}{consumeIcon} {title} – {artist}";
            format-stopped = "";
            format-disconnected = "";
            interval = 5;
            max-length = 40;
            state-icons = {
              playing = "󰐊";
              paused = "󰏤";
            };
            consume-icons = {
              on = "󰮯";
              off = "";
            };
            random-icons = {
              on = "󰒟";
              off = "";
            };
            repeat-icons = {
              on = "󰑖";
              off = "";
            };
            single-icons = {
              on = "󰎤";
              off = "";
            };
          };
          pulseaudio = {
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-right =
              "${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
            format-icons = {
              # TODO bluetooth + muted icons? (needs support upstream?)
              car = "󰄋";
              hands-free = "󰋎";
              hdmi = "󰡁";
              headphone = "󰋋";
              headset = "󰋎";
              hifi = "󰗜";
              phone = "󰏶";
              portable = "󰏶";
              default = [ "󰕿" "󰖀" "󰕾" ];
            };
            format = "{icon}{volume:3}%";
            format-bluetooth = "{icon}󰂯{volume:3}%";
            format-muted = "󰝟{volume:3}%";
          };
          backlight = {
            format = "{icon}{percent:3}%";
            format-icons = [ "󰌵" "󱉕" "󱉓" ];
            on-scroll-up = "${pkgs.light}/bin/light -A 1";
            on-scroll-down = "${pkgs.light}/bin/light -U 1";
            on-click-right = "${pkgs.light}/bin/light -S 100";
            on-click-middle = "${pkgs.light}/bin/light -S 0";
          };
          memory = {
            format = "󰩾 {used:0.2f}GiB";
            interval = 5;
          };
          cpu = {
            # TODO When 0.9.6 is released use format-state
            # https://github.com/Alexays/Waybar/pull/881
            format = "󰊚{usage:3}%";
            interval = 1;
          };
          temperature = {
            format = "󰔏{temperatureC}°C";
            format-critical = "󰸁 {temperatureC}°C";
            interval = 1;
            critical_threshold = 90;
            hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
          };
          disk = {
            format = "󰋊{percentage_used:3}%";
            interval = 60;
          };
          network = {
            format-wifi = "{icon}";
            interval = 20;
            format-ethernet = "󰈀";
            format-linked = "󰌷";
            format-icons = [ "󰤫" "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
            format-disconnected = "󰤮";
            on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
            tooltip-format =
              "󰩟{ipaddr} 󰀂{essid} {frequency} {icon}{signalStrength} 󰕒{bandwidthUpBits} 󰇚{bandwidthDownBits}";
          };
          bluetooth = {
            format-icons = {
              disabled = "󰂲";
              enabled = "󰂯";
            };
            on-click = "${pkgs.blueman}/bin/blueman-manager";
            # TODO rfkill to disable/enable on right click
          };
          battery = {
            format = "{icon}";
            rotate = 270;
            # TODO set different icons when charging (currently broken?)
            format-icons = [ "󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            states = {
              critical = 10;
              warning = 30;
            };
            # TODO % capacity in tooltip
          };
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "󰅶";
              deactivated = "󰾪";
            };
          };
          clock = {
            interval = 1;
            format = "󰅐 {:%T}";
            tooltip-format = "{:%F}";
          };
        };
      }];
      style = import ../config/waybar/style.nix;
    };

    wayland.windowManager.sway = let
      lockCommand = lib.concatStringsSep " " (with gruvbox;
        let rO = lib.removePrefix "#"; # remove Octothorpe
        in [
          "exec ${pkgs.swaylock-effects}/bin/swaylock"
          "--screenshots"
          "--clock"
          "--indicator"
          "--fade-in 1"
          "--font 'Myosevka'"
          "--inside-color ${rO dark.bg}"
          "--inside-clear-color ${rO light.yellow.bright}"
          "--inside-caps-lock-color ${rO light.orange.bright}"
          "--inside-ver-color ${rO light.purple.bright}"
          "--inside-wrong-color ${rO light.red.bright}"
          "--key-hl-color ${rO dark.cyan.bright}"
          "--line-color ${rO dark.bg}"
          "--line-clear-color ${rO dark.bg}"
          "--line-caps-lock-color ${rO dark.bg}"
          "--line-ver-color ${rO dark.bg}"
          "--line-wrong-color ${rO dark.bg}"
          "--ring-color ${rO light.cyan.bright}"
          "--ring-clear-color ${rO dark.yellow.bright}"
          "--ring-caps-lock-color ${rO dark.orange.bright}"
          "--ring-ver-color ${rO dark.purple.bright}"
          "--ring-wrong-color ${rO dark.red.normal}"
          "--separator-color ${rO dark.bg}"
          "--text-color ${rO dark.fg}"
          "--text-clear-color ${rO dark.fg}"
          "--text-caps-lock-color ${rO dark.fg}"
          "--text-ver-color ${rO dark.fg}"
          "--text-wrong-color ${rO dark.fg}"
          "--effect-pixelate 15"
          "--effect-blur 7x5"
        ]);
    in {
      enable = true;

      # https://github.com/NixOS/nixpkgs/issues/128469
      # sway does not like using the non-system mesa so get the sway binary
      # from the NixOS module
      package = null;

      config = rec {
        bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
        colors = {
          background = gruvbox.dark.bg;
          focused = {
            background = gruvbox.dark.bg;
            border = gruvbox.dark.bg;
            childBorder = gruvbox.dark.bg2;
            indicator = gruvbox.dark.bg4;
            text = gruvbox.dark.fg;
          };
          focusedInactive = {
            background = gruvbox.dark.bg;
            border = gruvbox.dark.bg;
            childBorder = gruvbox.dark.bg0_h;
            indicator = gruvbox.dark.bg0_h;
            text = gruvbox.dark.gray;
          };
          "placeholder" = {
            background = gruvbox.dark.bg0_s;
            border = gruvbox.dark.bg0_s;
            childBorder = gruvbox.dark.bg0_s;
            indicator = gruvbox.dark.bg0_s;
            text = gruvbox.dark.fg;
          };
          unfocused = {
            background = gruvbox.dark.bg2;
            border = gruvbox.dark.bg;
            childBorder = gruvbox.dark.bg0_h;
            indicator = gruvbox.dark.bg0_h;
            text = gruvbox.dark.gray;
          };
          urgent = {
            background = gruvbox.light.red.normal;
            border = gruvbox.light.red.normal;
            childBorder = gruvbox.light.red.normal;
            indicator = gruvbox.light.red.normal;
            text = gruvbox.dark.fg;
          };
        };
        floating = {
          border = 4;
          titlebar = true;
        };
        focus.followMouse = false;
        fonts = {
          names = [ "Myosevka Proportional" ];
          size = 14.0;
        };
        # gaps = { smartBorders = "on"; };
        input = {
          "*" = {
            xkb_numlock = "enabled";
            xkb_layout = "gb";
            xkb_options = "lv3:ralt_switch_multikey";
          };
        };
        keybindings = lib.mkOptionDefault {
          "${modifier}+b" = "splitv";
          "${modifier}+v" = "splith";
          "${modifier}+n" = "exec --no-startup-id ${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+e" = ''
            exec ${pkgs.sway}/bin/swaynag -t warning -f "Myosevka Proportional" -m "Exit sway?" -b "Yes" "${pkgs.sway}/bin/swaymsg exit"'';
          "${modifier}+Shift+x" = "${lockCommand}";
          "${modifier}+p" =
            "exec --no-startup-id ${pkgs.grim}/bin/grim ~/Pictures/screenshots/$(date +%F-%T).png";
          "Print" =
            "exec --no-startup-id ${pkgs.grim}/bin/grim ~/Pictures/screenshots/$(date +%F-%T).png";
          "XF86AudioRaiseVolume" =
            "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5%";
          "XF86AudioLowerVolume" =
            "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5%";
          "XF86AudioMute" =
            "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
          "XF86AudioPrev" =
            "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s previous";
          "XF86AudioNext" =
            "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s next";
          "XF86AudioPlay" =
            "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s play-pause";
          "XF86AudioStop" =
            "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s stop";
          "Control+XF86AudioPrev" =
            "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s position 30-";
          "Control+XF86AudioNext" =
            "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s position 30+";
          "Control+XF86AudioPlay" =
            "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s stop";
        };
        menu = ''
          ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term="${pkgs.foot}/bin/footclient" --dmenu="${pkgs.dmenu-wayland}/bin/dmenu-wl -i -fn 'Myosevka Proportional 14' -nb '${gruvbox.dark.bg}' -nf '${gruvbox.dark.fg}' -sb '${gruvbox.light.bg}' -sf '${gruvbox.light.fg}'"'';
        modifier = "Mod4";
        output = {
          "*" = {
            bg =
              "${pkgs.nixos-logo-gruvbox-wallpaper}/png/gruvbox-light-rainbow.png stretch";
          };
        };
        startup = [
          { command = "dbus-update-activation-environment WAYLAND_DISPLAY"; }
          {
            command =
              "${pkgs.swayidle}/bin/swayidle timeout 300 '${lockCommand} --grace 5' before-sleep '${lockCommand}'";
          }
        ];
        terminal = "${pkgs.foot}/bin/footclient";
        window = {
          border = 2;
          commands = [
            {
              criteria = { app_id = "kitty"; };
              command = "opacity 0.90";
            }
            {
              criteria = { app_id = "foot"; };
              command = "opacity 0.90";
            }
            {
              criteria = { class = "(?i)(emacs)"; };
              command = "opacity 0.90";
            }
          ];
        };
        workspaceAutoBackAndForth = true;
      };
      # Need to use extraConfig to enable i3 titlebar hiding behaviour
      extraConfig = ''
        hide_edge_borders --i3 both
      '';
      # systemdIntegration = true;
      # wrapperFeatures.gtk = true;
    };
  };
}
