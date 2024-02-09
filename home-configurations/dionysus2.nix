{ hmModules, pkgsForSystem }:

rec {
  pkgs = pkgsForSystem "x86_64-linux";

  modules = [
    (
      { config, lib, pkgs, ... }:
      {
        require = import ../modules/home/module-list.nix;

        home = {
          username = "corin";
          homeDirectory = "/home/corin";
          stateVersion = "21.11";
        };

        # Use ffmpeg build with nonfree components
        nixpkgs.overlays = [
          (self: super: {
            ffmpeg-full = super.ffmpeg-full.override {
              buildFfplay = false;
              withUnfree = true;
              # withLTO = true; # broken https://github.com/NixOS/nixpkgs/issues/139168
            };
          })
        ];

        programs = {
          beets.settings = {
            directory = "/mnt/storage/Music";
            library = "/opt/appdata/beets/musiclibrary.db";
            alternatives.transcoded = {
              query = "";
              directory = "/mnt/storage/excluded/transcoded-music";
              formats = "opus aac mp3 speex vorbis";
              removable = true;
            };
          };

          ## Machine-specifc dir hashes
          zsh.dirHashes = {
            appdata = "/opt/appdata";
            kopia = "/mnt/storage/backup/kopia";
            movies = "/mnt/storage/Movies";
            music = "/mnt/storage/Music";
            storage = "/mnt/storage";
            tv = "/mnt/storage/TV";
          };
        };

        systemd.user = {
          startServices = "sd-switch";
          servicesStartTimeoutMs = 1000;
          timers = {
            beet-update = {
              Unit = {
                Description = "Update music collection metadata with beets every month";
              };
              Timer = {
                OnCalendar = "*-*-13 23:00:00";
                RandomizedDelaySec = "9h";
                Persistent = true;
                Unit = "beet-update.service";
              };
              Install = {
                WantedBy = [ "timers.target" ];
              };
            };
          };
          services = {
            beet-update = {
              Unit = {
                Description = "Update music collection metadats with beets";
                After = "network.target";
              };
              Install.WantedBy = [ "default.target" ];
              Service = {
                Environment = [ "HOME=%h" ];
                ExecStartPre = [
                  "${pkgs.beets}/bin/beet update"
                ];
                ExecStart = [
                  "${pkgs.beets}/bin/beet fetchart"
                  "${pkgs.beets}/bin/beet lastgenre"
                  "${pkgs.beets}/bin/beet lyrics"
                  "${pkgs.beets}/bin/beet mbsync"
                ];
                Type = "oneshot";
                ProtectSystem = "full";
                PrivateTmp = true;
                Nice = 15;
                CPUSchedulingPolicy = "batch";
                IOSchedulingClass = "best-effort";
                IOSchedulingPriority = 4;
              };
            };
          };
        };

        lunik1.home = {
          core.enable = true;
          cli.enable = true;

          git.enable = true;
          gpg.enable = true;
          media-management.enable = true;
          neovim.enable = true;

          lang.nix.enable = true;
        };
      }
    )
  ] ++ hmModules;
}
