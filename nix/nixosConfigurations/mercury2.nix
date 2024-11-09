{
  system = "aarch64-linux";
  modules = [
    (
      {
        config,
        pkgs,
        lib,
        modulesPath,
        flake,
        ...
      }:
      let
        domain = "lunik.one";

        breezeWikiPort = 10416;
        favaPort = 5000;
        quetrePort = 3000;
        rssHubPort = 1200;
        wallabagPort = 4109;
      in
      {
        require = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        boot = {
          kernel.sysctl = {
            "net.core.default_qdisc" = "fq";
            "net.ipv4.tcp_congestion_control" = "bbr";
          };
          kernelModules = [ "softdog" ];
          kernelPackages = pkgs.linuxPackages;
          kernelParams = [ "console=tty" ];
          initrd.kernelModules = [ "virtio_gpu" ];

          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
        };

        environment.systemPackages = with pkgs; [
          matrix-synapse-tools.rust-synapse-compress-state
          pgcli
        ];

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "xfs";
          };
          "/boot" = {
            device = "/dev/disk/by-label/boot";
            fsType = "vfat";
          };
          "/var/lib" = {
            device = "/dev/disk/by-label/state";
            fsType = "xfs";
          };
        };

        swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

        security.acme = {
          acceptTerms = true;
          defaults.email = "xx.acme@themaw.xyz";
          certs."${domain}" = {
            extraDomainNames = [ "*.${domain}" ];
            dnsProvider = "porkbun";
            environmentFile = config.sops.secrets.acme-env.path;
          };
        };

        networking = {
          hostName = "mercury2";
          nftables.enable = true;
          firewall = {
            enable = lib.mkForce true;
            trustedInterfaces = [ "podman*" ];
            allowedUDPPorts = [
              21027 # syncthing
            ];
            allowedTCPPorts = [
              80 # http
              443 # https
              22000 # syncthing
            ];
          };
        };

        system.stateVersion = "23.05";

        nix.settings = {
          max-jobs = 2;
          cores = 4;
        };

        sops.secrets = {
          acme-env = {
            sopsFile = ../../secrets/host/mercury2/secrets.yaml;
            owner = "acme";
          };
          htaccess = {
            sopsFile = ../../secrets/host/mercury2/secrets.yaml;
            restartUnits = [ "nginx.service" ];
            owner = "nginx";
          };
          wallabag-env = {
            sopsFile = ../../secrets/host/mercury2/secrets.yaml;
            restartUnits = [ "podman-wallabag.service" ];
          };
        };

        services = {
          nginx =
            let
              mkNginxProxy =
                {
                  proxyPass,
                  auth ? true,
                  webSocket ? false,
                  extraConfig ? { },
                }:
                {
                  forceSSL = true;
                  quic = true;
                  sslCertificate = "/var/lib/acme/${domain}/cert.pem";
                  sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
                  sslTrustedCertificate = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                  locations."/" = {
                    inherit proxyPass;
                    recommendedProxySettings = true;
                    extraConfig = ''
                      proxy_connect_timeout 600;
                      proxy_send_timeout 600;
                      proxy_read_timeout 30m;
                    '';
                  } // lib.optionalAttrs webSocket { proxyWebsockets = true; };
                }
                // lib.optionalAttrs auth { basicAuthFile = config.sops.secrets.htaccess.path; }
                // extraConfig;

              localhost = port: "http://localhost:${toString port}";
            in
            {
              package = pkgs.angieQuic;

              recommendedOptimisation = true;
              recommendedTlsSettings = true;
              recommendedZstdSettings = true;
              recommendedGzipSettings = true;
              recommendedBrotliSettings = true;
              sslProtocols = "TLSv1.2 TLSv1.3";

              virtualHosts =
                {
                  default = {
                    default = true;
                    extraConfig = ''
                      ssl_reject_handshake on;
                    '';
                    locations."/".return = "444";
                  };
                  ${domain} = {
                    forceSSL = true;
                    quic = true;
                    locations."/".root = "/srv/www";
                    sslCertificate = "/var/lib/acme/${domain}/cert.pem";
                    sslTrustedCertificate = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
                  };
                  ${config.services.tt-rss.virtualHost} = {
                    serverName = "tt-rss.${domain}";
                    forceSSL = true;
                    quic = true;
                    basicAuthFile = config.sops.secrets.htaccess.path;
                    sslCertificate = "/var/lib/acme/${domain}/cert.pem";
                    sslTrustedCertificate = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
                  };
                }
                // builtins.listToAttrs (
                  map
                    (proxy: {
                      name = proxy.vhost;
                      value = mkNginxProxy (builtins.removeAttrs proxy [ "vhost" ]);
                    })
                    [
                      {
                        vhost = "atuin.${domain}";
                        proxyPass = localhost config.services.atuin.port;
                        auth = false;
                      }
                      {
                        vhost = "breezewiki.${domain}";
                        proxyPass = localhost breezeWikiPort;
                      }
                      {
                        vhost = "fava.${domain}";
                        proxyPass = localhost favaPort;
                      }
                      {
                        vhost = "netdata.${domain}";
                        proxyPass = localhost 19999;
                      }
                      {
                        vhost = "rsshub.${domain}";
                        proxyPass = localhost rssHubPort;
                      }
                      {
                        vhost = "synapse.${domain}";
                        proxyPass = "http://unix:${toString (builtins.head config.services.matrix-synapse.settings.listeners).path}";
                        auth = false;
                      }
                      {
                        vhost = "syncthing.${domain}";
                        proxyPass = "http://unix:${config.services.syncthing.guiAddress}";
                      }
                      {
                        vhost = "quetre.${domain}";
                        proxyPass = localhost quetrePort;
                      }
                      {
                        vhost = "thelounge.${domain}";
                        proxyPass = localhost config.services.thelounge.port;
                        auth = false;
                      }
                      {
                        vhost = "wallabag.${domain}";
                        proxyPass = localhost wallabagPort;
                        auth = false;
                      }
                    ]
                );
            };

          postgresql = {
            enable = true;
            package = pkgs.postgresql_16_jit;
            enableTCPIP = true;
            ensureDatabases = [ "wallabag" ];
            authentication = ''
              # podman containers
              host all all 10.0.0.0/0 trust
            '';
          };
          postgresqlBackup = {
            enable = true;
            startAt = "03:45:00";
            pgdumpOptions = "-Fc -Z zstd";
            compression = "none";
            databases = [
              "atuin"
              "matrix-synapse"
              "tt_rss"
              "wallabag"
            ];
          };

          redis = {
            vmOverCommit = true;
            servers = {
              rsshub.enable = true;
              wallabag.enable = true;
            };
          };

          atuin = {
            enable = true;
            openRegistration = false;
            database.createLocally = true;
          };

          matrix-synapse = {
            enable = true;
            enableRegistrationScript = false;
            withJemalloc = true;
            settings = {
              server_name = "${domain}";
              public_baseurl = "https://synapse.${domain}";
              max_upload_size = "100M";
              max_image_pixels = "64M";
              listeners = [
                {
                  path = "/run/matrix-synapse/matrix-synapse.sock";
                  mode = "660";
                  type = "http";
                  x_forwarded = true;
                  resources = [
                    {
                      names = [
                        "client"
                        "federation"
                      ];
                      compress = false;
                    }
                  ];
                }
              ];
              enable_registration = false;
              suppress_key_server_warning = true;
              trusted_key_servers = [
                {
                  server_name = "matrix.org";
                  verify_keys = {
                    "ed25519:auto" = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
                  };
                }
                {
                  server_name = "nixos.org";
                  verify_keys = {
                    "ed25519:j8tsLm" = "ysJrOC8kica9QA/fOCQT/lHJvcyCDnr1lCvXN0wsxwA";
                  };
                }
                {
                  server_name = "mozilla.org";
                  verify_keys = {
                    "ed25519:0" = "RsDggkM9GntoPcYySc8AsjvGoD0LVz5Ru/B/o5hV9h4";
                  };
                }
              ];
            };
            log.root.level = "WARNING";
          };

          netdata.enable = true;

          thelounge = {
            enable = true;
            plugins = with pkgs.theLoungePlugins; [ themes.zenburn ];
            extraConfig = {
              prefetch = true;
              prefetchStorage = true;
              prefetchMaxImageSize = 10240;
              maxHistory = 5000;
              leaveMessage = ":x";
            };
          };

          tt-rss = {
            enable = true;
            selfUrlPath = "https://tt-rss.${domain}";
            singleUserMode = true;
            plugins = [
              "auth_internal"
              "cache_starred_images"
              "toggle_sidebar"
            ];
            pluginPackages = [ pkgs.tt-rss-plugin-readability ];
            logDestination = "sql";
            database.createLocally = true;
          };

          syncthing = {
            enable = true;
            guiAddress = "/run/syncthing/syncthing.sock";
            settings = {
              gui.unixSocketPermissions = "664";
            };
          };
        };

        virtualisation.oci-containers.containers =
          let
            mkPodmanContainer = flake.outputs.lib.mkPodmanContainer config.time.timeZone;
          in
          {
            breezewiki = mkPodmanContainer {
              image = "quay.io/pussthecatorg/breezewiki";
              ports = [ "${toString breezeWikiPort}:${toString breezeWikiPort}" ];
              volumes = [ "breezewiki:/config:rw" ];
              environment = {
                BW_CANONICAL_ORIGIN = "https://breezewiki.${domain}";
                BW_PORT = toString breezeWikiPort;
              };
            };

            quetre = mkPodmanContainer {
              image = "codeberg.org/video-prize-ranch/quetre";
              volumes = [ "/etc/localtime:/etc/localtime:ro" ];
              ports = [ "${toString quetrePort}:3000" ];
            };

            rsshub = mkPodmanContainer {
              image = "diygod/rsshub:chromium-bundled";
              ports = [ "${toString rssHubPort}:1200" ];
              volumes = [ "${config.services.redis.servers.rsshub.unixSocket}:/run/redis/redis.sock" ];
              environment = {
                NODE_ENV = "production";
                CACHE_TYPE = "redis";
                REDIS_URL = "unix:///run/redis/redis.sock";
              };
              extraOptions = [ "--network=rss" ];
            };

            wallabag = mkPodmanContainer {
              image = "wallabag/wallabag";
              environmentFiles = [ config.sops.secrets.wallabag-env.path ];
              environment = {
                POSTGRES_USER = "wallabag";
                SYMFONY__ENV__DATABASE_HOST = "host.containers.internal";
                SYMFONY__ENV__DATABASE_DRIVER = "pdo_pgsql";
                SYMFONY__ENV__DATABASE_PORT = toString config.services.postgresql.settings.port;
                SYMFONY__ENV__DATABASE_NAME = "wallabag";
                SYMFONY__ENV__DATABASE_USER = "wallabag";
                SYMFONY__ENV__REDIS_SCHEME = "unix";
                SYMFONY__ENV__REDIS_PATH = "/run/redis/redis.sock";
                SYMFONY__ENV__DOMAIN_NAME = "https://wallabag.${domain}";
              };
              volumes = [
                "/run/postgresql:/run/postgresql"
                "${config.services.redis.servers.wallabag.unixSocket}:/run/redis/redis.sock"
                "wallabag-images:/var/www/wallabag/web/assets/images"
              ];
              ports = [ "${builtins.toString wallabagPort}:80" ];
              extraOptions = [ "--network=rss" ];
            };
          };

        systemd = {
          services =
            let
              mkPodmanVolume = flake.outputs.lib.mkPodmanVolume pkgs.podman;
              mkPodmanNetwork = flake.outputs.lib.mkPodmanNetwork pkgs.podman;
            in
            {
              fava = {
                description = "Fava Web UI for Beancount";
                after = [ "network.target" ];
                wants = [
                  "syncthing.service"
                  "nginx.service"
                ];
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  Type = "simple";
                  ExecStart =
                    "${pkgs.fava}/bin/fava "
                    + "--host 0.0.0.0 "
                    + "-p ${toString favaPort} "
                    + "--read-only /var/lib/syncthing/ledger/ledger.beancount";
                  User = "syncthing";
                  UMask = "0177";
                  LockPersonality = true;
                  MemoryDenyWriteExecute = true;
                  RestrictAddressFamilies = "AF_INET AF_INET6";
                  NoNewPrivileges = true;
                  PrivateDevices = true;
                  PrivateTmp = true;
                  PrivateUsers = true;
                  ProtectSystem = "strict";
                  ProtectProc = "invisible";
                  ProtectHome = true;
                  ProtectClock = true;
                  ProtectControlGroups = true;
                  ProtectHostname = true;
                  ProtectKernelLogs = true;
                  ProtectKernelModules = true;
                  ProtectKernelTunables = true;
                  ReadOnlyPaths = "/var/lib/syncthing/ledger";
                  RestrictNamespaces = true;
                  RestrictRealtime = true;
                  RestrictSUIDSGID = true;
                  SystemCallArchitectures = "native";
                  SystemCallErrorNumber = "EPERM";
                  SystemCallFilter = "@system-service";
                  CapabilityBoundingSet = "";
                };
              };
              matrix-synapse = rec {
                requires = [ "nginx.service" ];
                after = requires;
              };
              php-fpm-tt-rss = rec {
                partOf = [ "rss.target" ];
                wants = [
                  "nginx.service"
                  "podman-rsshub.service"
                ];
                after = wants;
              };
              thelounge = {
                wants = [ "nginx.service" ];
              };
              synapse-auto-compressor = {
                description = "Compress synapse database";
                requires = [ "postgresql.service" ];
                after = [ "postgresql.service" ];
                startAt = "Sat *-*-8..14 04:47:00"; # second saturday of the month @ 04:47 am
                serviceConfig = {
                  ExecStart =
                    "${lib.getExe' pkgs.matrix-synapse-tools.rust-synapse-compress-state "synapse_auto_compressor"} "
                    + "-p 'user=matrix-synapse dbname=matrix-synapse host=/run/postgresql' "
                    + "-c 2000 "
                    + "-n 500";
                  User = "matrix-synapse";
                  Type = "oneshot";
                  Nice = 15;
                  IOSchedulingPriority = 7;
                  CPUSchedulingPolicy = "batch";

                  CapabilityBoundingSet = "";
                  IPAddressDeny = "0.0.0.0/0 ::0";
                  LockPersonality = true;
                  MemoryDenyWriteExecute = true;
                  NoNewPrivileges = true;
                  PrivateDevices = true;
                  PrivateNetwork = true;
                  PrivateTmp = true;
                  PrivateUsers = true;
                  ProtectClock = true;
                  ProtectControlGroups = true;
                  ProtectHome = true;
                  ProtectHostname = true;
                  ProtectKernelLogs = true;
                  ProtectKernelModules = true;
                  ProtectKernelTunables = true;
                  ProtectProc = "invisible";
                  ProtectSystem = "strict";
                  RemoveIPC = true;
                  RestrictAddressFamilies = "AF_UNIX";
                  RestrictNamespaces = true;
                  RestrictRealtime = true;
                  RestrictSUIDSGID = true;
                  SystemCallArchitectures = "native";
                  SystemCallErrorNumber = "EPERM";
                  SystemCallFilter = "@system-service";
                  UMask = "0177";
                };
              };
              syncthing.serviceConfig.RuntimeDirectory = "syncthing";
              tt-rss = {
                partOf = [ "rss.target" ];
              };

              podman-breezewiki = {
                wants = [ "nginx.service" ];
              };
              podman-quetre = {
                wants = [ "nginx.service" ];
                partOf = [ "privacy-frontends.target" ];
              };
              podman-rsshub = {
                requires = [
                  "redis-rsshub.service"
                  "podman-network-rss.service"
                ];
                partOf = [ "rss.target" ];
                after = [
                  "redis-rsshub.service"
                  "podman-network-rss.service"
                ];
              };
              podman-wallabag = {
                requires = [
                  "postgresql.service"
                  "podman-network-rss.service"
                  "podman-volume-wallabag_images.service"
                ];
                partOf = [ "rss.target" ];
                after = [
                  "postgresql.service"
                  "podman-network-rss.service"
                  "podman-volume-wallabag_images.service"
                ];
              };

              podman-network-rss = mkPodmanNetwork "rss";

              podman-volume-wallabag_images = mkPodmanVolume "wallabag_images";
            };

          targets = {
            "privacy-frontends" = {
              wantedBy = [ "multi-user.target" ];
            };
            "rss" = {
              wantedBy = [ "multi-user.target" ];
            };
          };

          tmpfiles.rules = [
            "L+ /srv/www/.well-known/matrix/server - - - - ${
              builtins.toFile "server" (builtins.toJSON { "m.server" = "synapse.${domain}:443"; })
            }"
            "L+ /srv/www/.well-known/matrix/client - - - - ${
              builtins.toFile "client" (builtins.toJSON { "m.homeserver".base_url = "https://${domain}"; })
            }"
            "L+ /srv/www/robots.txt - - - - ${builtins.toFile "robots.txt" ''
              User-agent: *
              Disallow: /
            ''}"
          ];
        };

        users.users.nginx.extraGroups = [
          "acme"
          "matrix-synapse"
          "syncthing"
        ];

        lunik1.system = {
          backup.enable = true;
          containers.enable = true;
          headless.enable = true;
          network.resolved.enable = true;
          ssh-server.enable = true;
          zswap.enable = true;
        };
      }
    )
  ];
}
