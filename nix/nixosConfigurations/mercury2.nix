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

        autheliaSocket = "http://unix:///run/authelia/authelia.sock";

        anonymousoverflowPort = 13131;
        breezeWikiPort = 10416;
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
          rust-synapse-state-compress
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
            environmentFile = config.sops.templates."acme.env".path;
          };
        };

        networking = {
          hostName = "mercury2";
          nftables.enable = true;
          firewall = {
            enable = lib.mkForce true;
            trustedInterfaces = [ "podman*" ];
            allowedUDPPorts = [
              80 # http/3
              443 # https/3
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

        sops =
          let
            autheliaUser = config.services.authelia.instances.${domain}.user;
          in
          {
            secrets =
              let
                mercury2SopsFile = ../../secrets/host/mercury2/secrets.yaml;
              in
              {
                porkbun-api-key = {
                  sopsFile = mercury2SopsFile;
                  owner = "acme";
                };
                porkbun-secret-api-key = {
                  sopsFile = mercury2SopsFile;
                  owner = "acme";
                };
                anonymousoverflow-jwt-signing-secret = {
                  sopsFile = mercury2SopsFile;
                  restartUnits = [ "podman-anonymousoverflow.service" ];
                };
                authelia-jwt-key = {
                  sopsFile = mercury2SopsFile;
                  owner = autheliaUser;
                  restartUnits = [ "authelia-${domain}.service" ];
                };
                authelia-encryption-key = {
                  sopsFile = mercury2SopsFile;
                  owner = autheliaUser;
                  restartUnits = [ "authelia-${domain}.service" ];
                };
                authelia-session-secret = {
                  sopsFile = mercury2SopsFile;
                  owner = autheliaUser;
                  restartUnits = [ "authelia-${domain}.service" ];
                };
                authelia-corin-password = {
                  sopsFile = mercury2SopsFile;
                  owner = autheliaUser;
                  restartUnits = [ "authelia-${domain}.service" ];
                };
                kopia-repo-url = { };
                kopia-password = {
                  sopsFile = mercury2SopsFile;
                };
                wallabag-postgres-password = {
                  sopsFile = mercury2SopsFile;
                  restartUnits = [ "podman-wallabag.service" ];
                };
              };

            templates = with config.sops.placeholder; {
              "authelia-users.yaml" = {
                owner = autheliaUser;
                content = ''
                  users:
                      corin:
                          displayname: "Corin"
                          password: "${authelia-corin-password}"
                '';
              };
              "acme.env" = {
                owner = "acme";
                content = ''
                  PORKBUN_API_KEY=${porkbun-api-key}
                  PORKBUN_SECRET_API_KEY=${porkbun-secret-api-key}
                '';
              };
              "anonymousoverflow.env".content = ''
                JWT_SIGNING_SECRET=${anonymousoverflow-jwt-signing-secret}
              '';
              "wallabag.env".content = ''
                POSTGRES_PASSWORD=${wallabag-postgres-password}
                SYMFONY__ENV__DATABASE_PASSWORD=${wallabag-postgres-password}
              '';
            };
          };

        services = {
          authelia.instances = {
            ${domain} = {
              enable = true;
              settings = {
                default_2fa_method = "totp";
                authentication_backend.file.path = config.sops.templates."authelia-users.yaml".path;
                theme = "auto";
                session = {
                  cookies = [
                    {
                      inherit domain;
                      authelia_url = "https://auth.${domain}";
                      remember_me = "90d";
                    }
                  ];
                  redis.host = "/run/redis-authelia/redis.sock";
                };
                server = {
                  address = lib.strings.removePrefix "http://" "${autheliaSocket}?umask=0117";
                  endpoints.authz = {
                    auth-request.implementation = "AuthRequest";
                    basic = {
                      implementation = "AuthRequest";
                      authn_strategies = [
                        { name = "HeaderAuthorization"; }
                      ];
                    };
                  };
                };
                storage.postgres = rec {
                  address = "unix:///var/run/postgresql";
                  database = config.services.authelia.instances.${domain}.user;
                  username = database;
                  password = "1"; # has to be something, but doesn't matter what since we use peer auth
                };
                notifier.filesystem.filename = "/dev/null";
                access_control.default_policy = "one_factor";
                log = {
                  level = "info";
                  format = "text";
                };
              };
              secrets = with config.sops.secrets; {
                storageEncryptionKeyFile = authelia-encryption-key.path;
                sessionSecretFile = authelia-session-secret.path;
                jwtSecretFile = authelia-jwt-key.path;
              };
            };
          };

          nginx = {
            package = pkgs.angieQuic;

            recommendedOptimisation = true;
            recommendedTlsSettings = true;
            recommendedZstdSettings = true;
            recommendedGzipSettings = true;
            recommendedBrotliSettings = true;
            sslProtocols = "TLSv1.2 TLSv1.3";

            additionalModules = with pkgs.nginxModules; [
              develkit
              set-misc
            ];

            virtualHosts =
              let
                quic = true;
                forceSSL = true;

                sslCertificate = "/var/lib/acme/${domain}/cert.pem";
                sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
                sslTrustedCertificate = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

                internalAuth = "/internal/authelia/authz/auth";
                internalAuthDetect = "/internal/authelia/authz/detect";

                http3Conf = ''
                  add_header Alt-Svc 'h3=":$server_port"; ma=86400';
                '';

                noRobots = ''
                  add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
                '';

                # https://www.authelia.com/integration/proxies/nginx/#authelia-location-basicconf
                autheliaLocation = {
                  extraConfig =
                    http3Conf
                    + ''
                      internal;
                      proxy_pass $upstream_authelia;
                      proxy_set_header X-Original-Method $request_method;
                      proxy_set_header X-Original-URL $scheme://$host$request_uri;
                      proxy_set_header X-Forwarded-For $remote_addr;
                      proxy_set_header Content-Length "";
                      proxy_set_header Connection "";
                      proxy_pass_request_body off;
                      proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
                      proxy_redirect http:// $scheme://;
                      proxy_http_version 1.1;
                      proxy_cache_bypass $cookie_session;
                      proxy_no_cache $cookie_session;
                      proxy_buffers 4 32k;
                      client_body_buffer_size 128k;
                      send_timeout 5m;
                      proxy_read_timeout 240;
                      proxy_send_timeout 240;
                      proxy_connect_timeout 240;
                    '';
                };

                # https://www.authelia.com/integration/proxies/nginx/#authelia-authrequest-detectconf
                autheliaLocationDetect = {
                  extraConfig = ''
                    internal;
                    if ($is_basic_auth) {
                        return 401;
                    }
                    return 302 https://auth.${domain}/$is_args$args;
                  '';
                };

                # https://www.authelia.com/integration/proxies/nginx/#proxyconf
                autheliaProxyConf = ''
                  proxy_headers_hash_max_size 1024;
                  proxy_headers_hash_bucket_size 128;
                  # proxy_set_header Host $host; # this in the authelia config breaks some stuff
                  proxy_set_header X-Original-URL $scheme://$host$request_uri;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header X-Forwarded-Host $host;
                  proxy_set_header X-Forwarded-URI $request_uri;
                  proxy_set_header X-Forwarded-Ssl on;
                  proxy_set_header X-Forwarded-For $remote_addr;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-Server $host;
                  client_body_buffer_size 128k;
                  proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
                  proxy_redirect  http://  $scheme://;
                  proxy_http_version 1.1;
                  proxy_cache_bypass $cookie_session;
                  proxy_no_cache $cookie_session;
                  proxy_buffers 64 256k;
                  real_ip_header X-Forwarded-For;
                  real_ip_recursive on;
                  send_timeout 5m;
                  proxy_read_timeout 360;
                  proxy_send_timeout 360;
                  proxy_connect_timeout 360;
                '';

                # https://www.authelia.com/integration/proxies/nginx/#authelia-authrequest-detectconf
                autheliaAuthRequestConf = ''
                  auth_request ${internalAuth};
                  auth_request_set $user $upstream_http_remote_user;
                  auth_request_set $groups $upstream_http_remote_groups;
                  auth_request_set $name $upstream_http_remote_name;
                  auth_request_set $email $upstream_http_remote_email;
                  proxy_set_header Remote-User $user;
                  auth_request_set $redirection_url $upstream_http_location;
                  proxy_set_header Remote-Groups $groups;
                  proxy_set_header Remote-Name $name;
                  proxy_set_header Remote-Email $email;
                  set_escape_uri $target_url $scheme://$host$request_uri;
                  error_page 401 =302 ${internalAuthDetect}?rd=$target_url;
                '';

                autheliaConf = http3Conf + autheliaProxyConf + autheliaAuthRequestConf;

                basicAuthDetect = ''
                  set $upstream_authelia ${autheliaSocket}:/api/authz/auth-request;
                  set $is_basic_auth "";
                  if ($http_authorization ~* "^Basic ") {
                      # if basic auth was attempted, set $is_basic_auth and use authelia's basic auth endpoint
                      set $is_basic_auth "t";
                      set $upstream_authelia ${autheliaSocket}:/api/authz/basic;
                  }
                '';

                localhost = port: "http://localhost:${toString port}";

                mkProxyVirtualHost =
                  { serverName, proxyPass }:
                  {
                    inherit
                      quic
                      forceSSL
                      sslCertificate
                      sslCertificateKey
                      sslTrustedCertificate
                      serverName
                      ;
                    locations."/" = {
                      inherit proxyPass;
                      recommendedProxySettings = true;
                      extraConfig =
                        http3Conf
                        + noRobots
                        + ''
                          proxy_connect_timeout 360;
                          proxy_send_timeout 360;
                          proxy_read_timeout 360;
                        '';
                    };
                  };

                mkAuthenticatedProxyVirtualHost =
                  { serverName, proxyPass }:
                  {
                    inherit
                      quic
                      forceSSL
                      sslCertificate
                      sslCertificateKey
                      sslTrustedCertificate
                      serverName
                      ;
                    extraConfig = basicAuthDetect + noRobots;
                    locations = {
                      "/" = {
                        inherit proxyPass;
                        recommendedProxySettings = true;
                        extraConfig = autheliaConf;
                      };
                      ${internalAuth} = autheliaLocation;
                      ${internalAuthDetect} = autheliaLocationDetect;
                    };
                  };
              in
              {
                default = {
                  inherit sslCertificate sslTrustedCertificate sslCertificateKey;
                  addSSL = true;
                  default = true;
                  locations."/".return = "444";
                };
                ${domain} = {
                  inherit
                    quic
                    forceSSL
                    sslCertificate
                    sslTrustedCertificate
                    sslCertificateKey
                    ;
                  extraConfig = noRobots;
                  locations."/".root = "/srv/www";
                };
                ${config.services.tt-rss.virtualHost} = {
                  inherit
                    quic
                    forceSSL
                    sslCertificate
                    sslTrustedCertificate
                    sslCertificateKey
                    ;
                  serverName = "tt-rss.${domain}";
                  extraConfig = basicAuthDetect + noRobots;
                  locations = {
                    "/" = {
                      extraConfig = autheliaConf;
                    };
                    ${internalAuth} = autheliaLocation;
                    ${internalAuthDetect} = autheliaLocationDetect;
                  };
                };
                authelia = {
                  inherit
                    quic
                    forceSSL
                    sslCertificate
                    sslTrustedCertificate
                    sslCertificateKey
                    ;
                  serverName = "auth.${domain}";
                  extraConfig = noRobots;
                  locations = {
                    "/" = {
                      proxyPass = autheliaSocket;
                      extraConfig = autheliaProxyConf;
                    };
                    "/api/verify" = {
                      proxyPass = autheliaSocket;
                      extraConfig = http3Conf;
                    };
                    "/api/authz" = {
                      proxyPass = autheliaSocket;
                      extraConfig = http3Conf;
                    };
                  };
                };

                # virtual hosts with no auth
                atuin = mkProxyVirtualHost {
                  serverName = "atuin.${domain}";
                  proxyPass = localhost config.services.atuin.port;
                };
                synapse = mkProxyVirtualHost {
                  serverName = "synapse.${domain}";
                  proxyPass = "http://unix:${toString (builtins.head config.services.matrix-synapse.settings.listeners).path}";
                };
                thelounge = mkProxyVirtualHost {
                  serverName = "thelounge.${domain}";
                  proxyPass = localhost config.services.thelounge.port;
                };
                wallabag = mkProxyVirtualHost {
                  serverName = "wallabag.${domain}";
                  proxyPass = localhost wallabagPort;
                };

                # authelia-protected virtual hosts
                anonymousoverflow = mkAuthenticatedProxyVirtualHost {
                  serverName = "anonymousoverflow.${domain}";
                  proxyPass = localhost anonymousoverflowPort;
                };
                breezewiki = mkAuthenticatedProxyVirtualHost {
                  serverName = "breezewiki.${domain}";
                  proxyPass = localhost breezeWikiPort;
                };
                netdata = mkAuthenticatedProxyVirtualHost {
                  serverName = "netdata.${domain}";
                  proxyPass = localhost 19999;
                };
                quetre = mkAuthenticatedProxyVirtualHost {
                  serverName = "quetre.${domain}";
                  proxyPass = localhost quetrePort;
                };
                rsshub = mkAuthenticatedProxyVirtualHost {
                  serverName = "rsshub.${domain}";
                  proxyPass = localhost rssHubPort;
                };
                syncthing = mkAuthenticatedProxyVirtualHost {
                  serverName = "syncthing.${domain}";
                  proxyPass = "http://unix:${config.services.syncthing.guiAddress}";
                };
              };
          };

          postgresql =
            let
              autheliaUser = config.services.authelia.instances.${domain}.user;
            in
            {
              enable = true;
              package = pkgs.postgresql_16_jit;
              enableTCPIP = true;
              ensureDatabases = [
                autheliaUser
                "wallabag"
              ];
              ensureUsers = [
                {
                  name = autheliaUser;
                  ensureDBOwnership = true;
                }
              ];
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
              authelia = {
                enable = true;
                inherit (config.services.authelia.instances.${domain}) group;
              };
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
            anonymousoverflow = mkPodmanContainer {
              image = "ghcr.io/httpjamesm/anonymousoverflow:release";
              ports = [ "${toString anonymousoverflowPort}:8080" ];
              environmentFiles = [ config.sops.templates."anonymousoverflow.env".path ];
              environment = {
                APP_URL = "https://anonymousoverflow.${domain}";
              };
            };

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
              environmentFiles = [ config.sops.templates."wallabag.env".path ];
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
              "authelia-${domain}.service" = {
                requires = [ "postgresql.service" ];
                after = [ "postgresql.service" ];
                wants = [ "fail2ban.service" ]; # TODO put in fail2ban module
              };
              nginx = {
                wants = [ "authelia-${domain}.service" ];
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
                    "${lib.getExe' pkgs.rust-synapse-state-compress "synapse_auto_compressor"} "
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

              podman-anonymousoverflow = {
                wants = [ "nginx.service" ];
                partOf = [ "privacy-frontends.target" ];
              };
              podman-breezewiki = {
                wants = [ "nginx.service" ];
                partOf = [ "privacy-frontends.target" ];
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
            "D /run/authelia - ${config.services.authelia.instances.${domain}.user} ${
              config.services.authelia.instances.${domain}.group
            } - -"
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
          config.services.authelia.instances.${domain}.group
        ];

        lunik1.system = {
          containers.enable = true;
          fail2ban.enable = true;
          headless.enable = true;
          kopia-backup = {
            enable = true;
            interval = "04:07";
            urlFile = config.sops.secrets.kopia-repo-url.path;
            passwordFile = config.sops.secrets.kopia-password.path;
          };
          network.resolved.enable = true;
          ssh-server.enable = true;
          zswap.enable = true;
        };
      }
    )
  ];
}
