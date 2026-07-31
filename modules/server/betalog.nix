{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.hannes.services.betalog;
  secretEnv = "betalog.env";

  backend = pkgs.buildGoModule {
    pname = "betalog-backend";
    version = "1.0.0";
    src = inputs.betalog-src;

    vendorHash = "sha256-u7fXnfEJMuI08UBvSS1JD77Fh8Mh0pN51XpM409MbMQ=";
    subPackages = [ "cmd/api" ];

    env.CGO_ENABLED = "0";

    postBuild = ''
      go build -o $GOPATH/bin/migrate ./migrate.go
    '';

    postInstall = ''
      mv $out/bin/api $out/bin/server
    '';
  };

  frontend = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "betalog-frontend";
    version = "1.0.0";
    src = "${inputs.betalog-src}/ui";

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.pnpm_11
      pkgs.pnpmConfigHook
    ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 3;
      hash = "sha256-7jYAsuhj3bJEkff0YHaqHbrR0JccF4VpdOXp0i2BKas=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out

      cp -r ../public/. $out/

      runHook postInstall
    '';
  });
in
{
  options.hannes.services.betalog = {
    enable = mkEnableOption "betalog";

    domain = mkOption {
      type = types.str;
      default = "betalog.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "betalog" ];
      ensureUsers = [
        {
          name = "betalog";
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.betalog = {
      description = "Betalog Application Service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.service"
      ];
      requires = [ "postgresql.service" ];

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "betalog";
        WorkingDirectory = "/var/lib/betalog";

        EnvironmentFile = config.age.secrets.${secretEnv}.path;

        BindReadOnlyPaths = [
          "${frontend}:/var/lib/betalog/public"
          "${inputs.betalog-src}/config:/var/lib/betalog/config"
        ];

        ExecStartPre = "${backend}/bin/migrate";
        ExecStart = "${backend}/bin/server";

        Environment = [
          "APP_ENV=production"
          "SERVER_PORT=${toString cfg.port}"
          "SERVER_HOST=127.0.0.1"

          "DB_HOST=/run/postgresql"
          "DB_DATABASE=betalog"
          "DB_USER=betalog"

          "AUTH_OIDC_DISCOVERY_URL=https://${config.hannes.services.pocket-id.domain}/.well-known/openid-configuration"
          "AUTH_OIDC_CALLBACK_URL=https://${cfg.domain}/api/auth/callback/openid-connect"

          "LOGGER_LEVEL=info"
        ];

        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
