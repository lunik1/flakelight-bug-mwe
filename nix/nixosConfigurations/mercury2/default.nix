{
  inputs,
  outputs,
  hmModules,
  ...
}:

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

        breezeWikiPort = 10416;
        minifluxPort = 1272;
        mkfdPort = 5000;
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
          rust-synapse-compress-state
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
                mercury2SopsFile = ../../../secrets/host/mercury2/secrets.yaml;
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
                authelia-jwt-key = {
                  sopsFile = mercury2SopsFile;
                  owner = autheliaUser;
                  restartUnits = [ "authelia-${domain}.service" ];
                };
                authelia-jwks-key = {
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
                authelia-corin-email = {
                  sopsFile = mercury2SopsFile;
                  owner = autheliaUser;
                  restartUnits = [ "authelia-${domain}.service" ];
                };
                miniflux-admin-password = {
                  sopsFile = mercury2SopsFile;
                };
                miniflux-admin-user = {
                  sopsFile = mercury2SopsFile;
                };
                miniflux-oidc-secret = {
                  sopsFile = mercury2SopsFile;
                };
                mkfd-passkey = {
                  sopsFile = mercury2SopsFile;
                };
                mkfd-cookie-secret = {
                  sopsFile = mercury2SopsFile;
                };
                mkfd-encryption-key = {
                  sopsFile = mercury2SopsFile;
                };
                kopia-repo-url = { };
                kopia-password = {
                  sopsFile = mercury2SopsFile;
                };
                wallabag-postgres-password = {
                  sopsFile = mercury2SopsFile;
                  restartUnits = [ "wallabag.service" ];
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
                          email: "${authelia-corin-email}"
                '';
              };
              "acme.env" = {
                owner = "acme";
                content = ''
                  PORKBUN_API_KEY=${porkbun-api-key}
                  PORKBUN_SECRET_API_KEY=${porkbun-secret-api-key}
                '';
              };
              miniflux-admin-credentials.content = ''
                ADMIN_USERNAME=${miniflux-admin-user}
                ADMIN_PASSWORD=${miniflux-admin-password}
                OAUTH2_CLIENT_SECRET=${miniflux-oidc-secret}
              '';
              "mkfd.env".content = ''
                PASSKEY=${mkfd-passkey}
                COOKIE_SECRET=${mkfd-cookie-secret}
                ENCRYPTION_KEY=${mkfd-encryption-key}
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
                identity_providers.oidc = {
                  jwks = {
                    # key provided by extra settings file
                    # see https://github.com/NixOS/nixpkgs/pull/299309#issuecomment-2108501250
                    algorithm = "RS256";
                    use = "sig";
                  };
                  clients = [
                    {
                      client_id = "miniflux";
                      client_name = "Miniflux";
                      client_secret = "$pbkdf2-sha512$310000$CsT7PqW7JXAkYumwQ8LZPQ$0MA4LMAjwLe5idkHRvLqLF2VRgvfF2twUGqYy82yXTpgMQlvPhTaS1ozPV.TihJatBuNRFt4Xu2uBlfe8li.6A";
                      public = false;
                      authorization_policy = "one_factor";
                      require_pkce = "false";
                      redirect_uris = [
                        "https://miniflux.${domain}/oauth2/oidc/callback"
                      ];
                      scopes = [
                        "openid"
                        "profile"
                        "email"
                      ];
                      response_types = [ "code" ];
                      grant_types = [ "authorization_code" ];
                      token_endpoint_auth_method = "client_secret_post";
                    }
                    {
                      client_id = "beszel";
                      client_name = "Beszel";
                      client_secret = "$pbkdf2-sha512$310000$DnnW0oYkRLD9ZPWFScszPQ$JfjbYqqq4yaZ0zossLw9Uc7GIuVKMmKSmR2XJqQkvwfO4hxpDwVaYcRXA1M.As7a0/jMC6mAFvoTzeV.R.Qzyg";
                      public = false;
                      authorization_policy = "one_factor";
                      require_pkce = "false";
                      redirect_uris = [
                        "https://beszel.${domain}/api/oauth2-redirect"
                      ];
                      scopes = [
                        "openid"
                        "profile"
                        "email"
                      ];
                      response_types = [ "code" ];
                      grant_types = [ "authorization_code" ];
                      token_endpoint_auth_method = "client_secret_post";
                    }
                  ];
                };
              };
              secrets = with config.sops.secrets; {
                storageEncryptionKeyFile = authelia-encryption-key.path;
                sessionSecretFile = authelia-session-secret.path;
                jwtSecretFile = authelia-jwt-key.path;
              };
              environmentVariables = {
                X_AUTHELIA_CONFIG_FILTERS = "template";
              };
              settingsFiles = [ ./authelia-extra.yaml ];
            };
          };

          nginx = {
            enable = true;
            package = pkgs.angie;

            recommendedOptimisation = true;
            recommendedTlsSettings = true;
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
                  extraConfig = http3Conf + ''
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
                cinny = {
                  inherit
                    quic
                    forceSSL
                    sslCertificate
                    sslTrustedCertificate
                    sslCertificateKey
                    ;
                  serverName = "cinny.${domain}";
                  extraConfig = basicAuthDetect + noRobots;
                  locations = {
                    "/" = {
                      root = "${pkgs.cinny}";
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
                beszel = mkProxyVirtualHost {
                  serverName = "beszel.${domain}";
                  proxyPass = localhost config.services.beszel.hub.port;
                };
                miniflux = mkProxyVirtualHost {
                  serverName = "miniflux.${domain}";
                  proxyPass = localhost minifluxPort;
                };
                mkfd = mkProxyVirtualHost {
                  serverName = "mkfd.${domain}";
                  proxyPass = localhost mkfdPort;
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
                breezewiki = mkAuthenticatedProxyVirtualHost {
                  serverName = "breezewiki.${domain}";
                  proxyPass = localhost breezeWikiPort;
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

          beszel = {
            hub = {
              enable = true;
              host = "0.0.0.0";
              environment = {
                DISABLE_PASSWORD_AUTH = "true";
                SHARE_ALL_SYSTEMS = "true";
                # USER_CREATION = "true";
              };
            };
            agent = {
              enable = true;
              environment = {
                KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyN6C37Yx8Eu5bEivviT3iN1bDsRWaKLih3GRWwZPoY";
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

          synapse-auto-compressor = {
            enable = true;
            package = pkgs.rust-synapse-compress-state; # remove once nicpkgs#455644 is merged
            startAt = "Sat *-*-8..14 04:47:00";
            settings = {
              chunks_to_compress = 500;
              chunk_size = 2000;
            };
          };

          thelounge = {
            enable = true;
            plugins = with pkgs; [ lunik1-nur.thelounge-theme-zenburn ];
            extraConfig = {
              prefetch = true;
              prefetchStorage = true;
              prefetchMaxImageSize = 10240;
              maxHistory = 5000;
              leaveMessage = ":x";
            };
          };

          miniflux = {
            enable = true;
            createDatabaseLocally = true;
            adminCredentialsFile = config.sops.templates.miniflux-admin-credentials.path;
            config = {
              BASE_URL = "https://miniflux.${domain}";
              WORKER_POOL_SIZE = 4;
              HTTP_CLIENT_TIMEOUT = 60;
              LISTEN_ADDR = "0.0.0.0:${toString minifluxPort}";
              OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.${domain}";
              OAUTH2_CLIENT_ID = "miniflux";
              OAUTH2_OIDC_PROVIDER_NAME = "Authelia";
              OAUTH2_PROVIDER = "oidc";
              OAUTH2_REDIRECT_URL = "https://miniflux.${domain}/oauth2/oidc/callback";
              POLLING_FREQUENCY = 15;
              POLLING_PARSING_ERROR_LIMIT = 10;
              PORT = minifluxPort;
              SCHEDULER_ROUND_ROBIN_MIN_INTERVAL = 15;
              # OAUTH2_USER_CREATION = 1;
            };
          };

          syncthing = {
            enable = true;
            guiAddress = "/run/syncthing/syncthing.sock";
            settings = {
              gui.unixSocketPermissions = "664";
            };
          };
        };

        virtualisation.quadlet =
          let
            inherit (config.virtualisation.quadlet) networks;
          in
          {
            enable = true;
            autoEscape = true;

            autoUpdate = {
              enable = true;
              calendar = "*-*-* 05:37:12";
            };

            networks = {
              rss = { };
            };

            volumes = {
              breezewiki = { };
              wallabag_images = { };
            };

            containers = {
              breezewiki = {
                containerConfig = {
                  image = "quay.io/pussthecatorg/breezewiki";
                  autoUpdate = "registry";
                  publishPorts = [ "${toString breezeWikiPort}:${toString breezeWikiPort}" ];
                  environments = {
                    BW_CANONICAL_ORIGIN = "https://breezewiki.${domain}";
                    BW_PORT = toString breezeWikiPort;
                  };
                  volumes = [ "breezewiki:/config:rw" ];
                  tmpfses = [
                    "/tmp"
                    "/run"
                  ];
                };
                unitConfig = {
                  Wants = [ "nginx.service" ];
                  PartOf = [ "privacy-frontends.target" ];
                };
              };

              mkfd = {
                containerConfig = {
                  image = "docker.io/tbosk/mkfd";
                  autoUpdate = "registry";
                  publishPorts = [ "${toString mkfdPort}:5000" ];
                  environmentFiles = [ config.sops.templates."mkfd.env".path ];
                  tmpfses = [
                    "/tmp"
                    "/run"
                  ];
                  networks = [ networks.rss.ref ];
                };
                unitConfig = {
                  PartOf = [ "rss.target" ];
                };
              };

              rsshub = {
                containerConfig = {
                  image = "docker.io/diygod/rsshub:chromium-bundled";
                  autoUpdate = "registry";
                  publishPorts = [ "${toString rssHubPort}:1200" ];
                  environments = {
                    NODE_ENV = "production";
                    CACHE_TYPE = "redis";
                    REDIS_URL = "unix:///run/redis/redis.sock";
                  };
                  volumes = [ "${config.services.redis.servers.rsshub.unixSocket}:/run/redis/redis.sock" ];
                  tmpfses = [
                    "/tmp"
                    "/run"
                  ];
                  networks = [ networks.rss.ref ];
                };
                unitConfig = rec {
                  After = [ "redis-rsshub.service" ];
                  Requires = After;
                  PartOf = [ "rss.target" ];
                };
              };

              wallabag = {
                containerConfig = {
                  image = "docker.io/wallabag/wallabag";
                  autoUpdate = "registry";
                  publishPorts = [ "${builtins.toString wallabagPort}:80" ];
                  environments = {
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
                  environmentFiles = [ config.sops.templates."wallabag.env".path ];
                  volumes = [
                    "/run/postgresql:/run/postgresql"
                    "${config.services.redis.servers.wallabag.unixSocket}:/run/redis/redis.sock"
                    "wallabag-images:/var/www/wallabag/web/assets/images"
                  ];
                  tmpfses = [
                    "/tmp"
                    "/run"
                  ];
                  networks = [ networks.rss.ref ];
                };
                unitConfig = rec {
                  After = [
                    "postgresql.service"
                    "redis-wallabag.service"
                  ];
                  Requires = After;
                  PartOf = [ "rss.target" ];
                };
              };
            };
          };

        systemd = {
          services = {
            "authelia-${domain}.service" = {
              requires = [ "postgresql.service" ];
              after = [ "postgresql.service" ];
              wants = [ "fail2ban.service" ]; # TODO put in fail2ban module
            };
            nginx = {
              wants = [ "authelia-${domain}.service" ];
            };
            beszel-agent = {
              wants = [ "beszel-hub.service" ];
            };
            beszel-hub = {
              wants = [
                "nginx.service"
                "authelia-${domain}.service"
              ];
            };
            matrix-synapse = rec {
              requires = [ "nginx.service" ];
              after = requires;
            };
            thelounge = {
              wants = [ "nginx.service" ];
            };
            syncthing.serviceConfig.RuntimeDirectory = "syncthing";
            miniflux = {
              partOf = [ "rss.target" ];
              # EnvironmentFile = config.sops.templates."miniflux.env".path;
            };
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

        users = {
          users.nginx = {
            extraGroups = [
              "acme"
              "matrix-synapse"
              "syncthing"
              config.services.authelia.instances.${domain}.group
            ];
          };
          groups.redis-authelia = { };
        };

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

        home-manager.users.corin = {
          imports = hmModules;

          home = {
            username = "corin";
            homeDirectory = "/home/corin";
            stateVersion = "23.05";
          };

          programs.pgcli.enable = true;

          lunik1.home = {
            cli.enable = true;

            git.enable = true;
            gpg.enable = true;
            neovim.enable = true;

            lang.nix.enable = true;
          };
        };
      }
    )
  ];
}
