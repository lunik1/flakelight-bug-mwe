{
  config,
  lib,
  pkgs,
  ...
}:

let
  gruvbox = import ../../resources/colourschemes/gruvbox.nix;
  cfg = config.lunik1.home;
in
{
  options.lunik1.home = {
    sway.enable = lib.mkEnableOption "sway";
    waybar = {
      batteryModule = lib.mkEnableOption "Enable the battery module in Waybar";
      bluetoothModule = lib.mkEnableOption "Enable the bluetooth module in Waybar";
    };
  };

  config = lib.mkIf cfg.sway.enable {
    home = {
      packages = with pkgs; [
        foot
        networkmanager_dmenu
        networkmanagerapplet
        ungoogled-chromium
        wev
        xfce.thunar

        # Fonts
        material-design-icons

        lunik1-nur.myosevka.mono
        lunik1-nur.myosevka.proportional
      ];

      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
      };
    };

    programs = {
      foot = {
        enable = true;
        server.enable = true;
        settings = {
          main = {
            font = "Myosevka Light:size=14.0";
            box-drawings-uses-font-glyphs = true;
          };
          scrollback.lines = 5000;
          cursor.blink = true;
          colors = builtins.mapAttrs (_: lib.removePrefix "#") {
            foreground = gruvbox.dark.fg;
            background = gruvbox.dark.bg;
            regular0 = gruvbox.dark.black.normal;
            regular1 = gruvbox.dark.red.normal;
            regular2 = gruvbox.dark.green.normal;
            regular3 = gruvbox.dark.yellow.normal;
            regular4 = gruvbox.dark.blue.normal;
            regular5 = gruvbox.dark.purple.normal;
            regular6 = gruvbox.dark.cyan.normal;
            regular7 = gruvbox.dark.white.normal;
            bright0 = gruvbox.dark.black.bright;
            bright1 = gruvbox.dark.red.bright;
            bright2 = gruvbox.dark.green.bright;
            bright3 = gruvbox.dark.yellow.bright;
            bright4 = gruvbox.dark.blue.bright;
            bright5 = gruvbox.dark.purple.bright;
            bright6 = gruvbox.dark.cyan.bright;
            bright7 = gruvbox.dark.white.bright;
            urls = gruvbox.dark.orange.normal;
          };
        };
      };
      waybar = {
        enable = true;
        package = pkgs.waybar;
        settings = [
          {
            layer = "bottom";
            position = "bottom";
            # output = [ "eDP-1" ];
            height = 35;
            modules-left = [
              "sway/workspaces"
              "sway/mode"
              "idle_inhibitor"
              "mpd"
            ];
            modules-right =
              with config.lunik1.home.waybar;
              (
                [
                  "temperature"
                  "cpu"
                  "backlight"
                ]
                ++ lib.optional batteryModule "battery"
                ++ [
                  "custom/memory"
                  "disk"
                  "network"
                ]
                ++ lib.optional bluetoothModule "bluetooth"
                ++ [
                  "pulseaudio"
                  "clock"
                  # "tray"
                ]
              );
            modules = {
              "sway/workspaces".numeric-first = true;
              mpd = {
                format = "{stateIcon}{repeatIcon}{randomIcon}{singleIcon}{consumeIcon} {title} – {artist}";
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
                on-click-right = "${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
                format-icons = {
                  # TODO bluetooth + muted icons? (needs support upstream?)
                  car = "󰄋";
                  handsfree = "󰋎";
                  hdmi = "󰡁";
                  headphones = "󰋋";
                  headset = "󰋎";
                  hifi = "󰗜";
                  phone = "󰏶";
                  portable = "󰏶";
                  default = [
                    "󰕿"
                    "󰖀"
                    "󰕾"
                  ];
                };
                format = "{icon}{volume:3}%";
                format-bluetooth = "{icon}󰂯{volume:3}%";
                format-muted = "󰝟{volume:3}%";
              };
              backlight = {
                format = "{icon}";
                format-icons = [
                  "󰛩"
                  "󱩎"
                  "󱩏"
                  "󱩐"
                  "󱩑"
                  "󱩒"
                  "󱩓"
                  "󱩔"
                  "󱩕"
                  "󱩖"
                  "󰛨"
                ];
                on-scroll-up = "${pkgs.light}/bin/light -A 1";
                on-scroll-down = "${pkgs.light}/bin/light -U 1";
                on-click-right = "${pkgs.light}/bin/light -S 100";
                on-click-middle = "${pkgs.light}/bin/light -S 0";
              };
              "custom/memory" = {
                exec = "${pkgs.procps}/bin/free -b | ${pkgs.gawk}/bin/gawk -f ${../../resources/waybar/memory_module.awk}";
                return-type = "json";
                interval = 5;
              };
              cpu = {
                format = "{icon}";
                format-icons = [
                  "󰡳"
                  "󰡵"
                  "󰊚"
                  "󰡴"
                ];
                interval = 1;
              };
              temperature = {
                format-icons = [
                  "󰜗"
                  "󱃃"
                  "󰔏"
                  "󱃂"
                  "󰸁"
                ];
                format = "󰔏{temperatureC}°C";
                interval = 1;
                critical_threshold = 90;
                hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
              };
              disk = {
                states =
                  let
                    nIcons = 9;
                  in
                  builtins.listToAttrs (
                    map (x: {
                      "name" = builtins.toString x;
                      "value" = builtins.floor ((x * 100.0) / (nIcons - 1) + 0.5);
                    }) (lib.range 0 (nIcons - 1))
                  );
                format-0 = "󰝦";
                format-1 = "󰪞";
                format-2 = "󰪟";
                format-3 = "󰪠";
                format-4 = "󰪡";
                format-5 = "󰪢";
                format-6 = "󰪣";
                format-7 = "󰪤";
                format-8 = "󰪥";
                interval = 60;
              };
              network = {
                format-wifi = "{icon}";
                interval = 20;
                format-ethernet = "󰈀";
                format-linked = "󰌷";
                format-icons = [
                  "󰤫"
                  "󰤯"
                  "󰤟"
                  "󰤢"
                  "󰤥"
                  "󰤨"
                ];
                format-disconnected = "󰤮";
                on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
                tooltip-format = "󰩟{ipaddr} 󰀂{essid} {frequency} {icon}{signalStrength} 󰕒{bandwidthUpBits} 󰇚{bandwidthDownBits}";
              };
              bluetooth = {
                format-icons = {
                  disabled = "󰂲";
                  enabled = "󰂯";
                };
                format = "{icon}";
                on-click = "${pkgs.blueman}/bin/blueman-manager";
                on-click-right = "${pkgs.utillinux}/bin/rfkill toggle bluetooth";
              };
              battery = {
                format = "{icon}";
                rotate = 270;
                # TODO set different icons when charging (currently broken?)
                format-icons = [
                  "󱃍"
                  "󰁺"
                  "󰁻"
                  "󰁼"
                  "󰁽"
                  "󰁾"
                  "󰁿"
                  "󰂀"
                  "󰂁"
                  "󰂂"
                  "󰁹"
                ];
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
          }
        ];
        style = import ../../config/waybar/style.nix;
      };
      zathura = {
        enable = true;
        options = import ../../config/zathura/zathura.nix;
      };
    };

    wayland.windowManager.sway =
      let
        lockCommand = lib.concatStringsSep " " (
          with gruvbox;
          let
            rO = lib.removePrefix "#"; # remove Octothorpe
          in
          [
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
          ]
        );
      in
      {
        enable = true;

        # https://github.com/NixOS/nixpkgs/issues/128469
        # sway does not like using the non-system mesa so get the sway binary
        # from the NixOS module
        package = null;

        config = rec {
          bars = [ { command = "${pkgs.waybar}/bin/waybar"; } ];
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
              xkb_options = "compose:ralt";
            };
          };
          keybindings = lib.mkOptionDefault {
            "${modifier}+b" = "splitv";
            "${modifier}+v" = "splith";
            "${modifier}+n" = "exec --no-startup-id ${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+Shift+e" = ''exec ${pkgs.sway}/bin/swaynag -t warning -f "Myosevka Proportional" -m "Exit sway?" -b "Yes" "${pkgs.sway}/bin/swaymsg exit"'';
            "${modifier}+Shift+x" = "${lockCommand}";
            "${modifier}+p" = "exec --no-startup-id ${pkgs.grim}/bin/grim ~/Pictures/screenshots/$(date +%F-%T).png";
            "Print" = "exec --no-startup-id ${pkgs.grim}/bin/grim ~/Pictures/screenshots/$(date +%F-%T).png";
            "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5%";
            "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5%";
            "XF86AudioMute" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
            "XF86AudioPrev" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s previous";
            "XF86AudioNext" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s next";
            "XF86AudioPlay" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s play-pause";
            "XF86AudioStop" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s stop";
            "Control+XF86AudioPrev" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s position 30-";
            "Control+XF86AudioNext" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s position 30+";
            "Control+XF86AudioPlay" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl -s stop";
          };
          menu = ''${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --term="${pkgs.foot}/bin/footclient" --dmenu="${pkgs.dmenu-wayland}/bin/dmenu-wl -i -fn 'Myosevka Proportional 14' -nb '${gruvbox.dark.bg}' -nf '${gruvbox.dark.fg}' -sb '${gruvbox.light.bg}' -sf '${gruvbox.light.fg}'"'';
          modifier = "Mod4";
          output = {
            "*" = {
              bg = "${
                pkgs.nix-wallpaper.override { preset = "gruvbox-light-rainbow"; }
              }/share/wallpapers/nixos-wallpaper.png stretch";
            };
          };
          startup = [
            {
              command = "dbus-update-activation-environment --systemd PATH DISPLAY WAYLAND_DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP";
            }
            {
              command = "${pkgs.swayidle}/bin/swayidle timeout 300 '${lockCommand} --grace 5' before-sleep '${lockCommand}'";
            }
          ];
          terminal = "${pkgs.foot}/bin/footclient";
          window = {
            border = 2;
            commands = [
              {
                criteria = {
                  app_id = "kitty";
                };
                command = "opacity 0.90";
              }
              {
                criteria = {
                  app_id = "foot";
                };
                command = "opacity 0.90";
              }
              {
                criteria = {
                  class = "(?i)(emacs)";
                };
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

    xdg = {
      enable = true;
      configFile = {
        "networkmanager_dmenu" = {
          text = ''
            [dmenu]
            dmenu_command = ${pkgs.dmenu-wayland}/bin/dmenu-wl
            fn = Myosevka Proportional 14
            nb = ${gruvbox.dark.bg}
            nf = ${gruvbox.dark.fg}
            sb = ${gruvbox.light.bg}
            sf =  ${gruvbox.light.fg}
            pinentry = ${pkgs.pinentry.gnome3}/bin/pinentry-gnome3
            wifi_chars = ▂▄▆█

            [editor]
            terminal = foot
          '';
          target = "networkmanager-dmenu/config.ini";
        };
      };
      mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "thunar.desktop" ];
          "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "appliction/oxps" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "application/x-fictionbook" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
          "application/x-cbr" = [ "org.pwmt.zathura-cb.desktop" ];
          "application/x-cb7" = [ "org.pwmt.zathura-cb.desktop" ];
          "application/x-cbt" = [ "org.pwmt.zathura-cb.desktop" ];
          "image/vnd.djvu" = [ "org.pwmt.zathura-djvu.desktop" ];
          "image/vnd.djvu+multipage" = [ "org.pwmt.zathura-djvu.desktop" ];
          "application/postscript" = [ "org.pwmt.zathura-ps.desktop" ];
          "application/eps" = [ "org.pwmt.zathura-ps.desktop" ];
          "application/x-eps" = [ "org.pwmt.zathura-ps.desktop" ];
          "image/eps" = [ "org.pwmt.zathura-ps.desktop" ];
          "image/x-eps" = [ "org.pwmt.zathura-ps.desktop" ];
        };
      };
    };
  };
}
