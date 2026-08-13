{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.hannes.services.moneymatter;
  secretEnv = "moneymatter.env";
in
{
  options.hannes.services.moneymatter = {
    enable = mkEnableOption "Budget Tracker";

    domain = mkOption {
      type = types.str;
      default = "money.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 30145;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    systemd.services.moneymatter-network = {
      description = "network for moneymatter";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.podman}/bin/podman network create moneymatter";
        ExecStop = "${pkgs.podman}/bin/podman network rm moneymatter";
      };
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        moneymatter-db = {
          image = "postgres:16-alpine";
          environment = {
            POSTGRES_DB = "budget";
            POSTGRES_USER = "budget";
          };
          environmentFiles = [
            config.age.secrets.${secretEnv}.path
          ];
          volumes = [
            "moneymatter-db-data:/var/lib/postgresql/data"
          ];
          extraOptions = [
            "--network=moneymatter"
          ];
        };

        moneymatter-redis = {
          image = "redis:7-alpine";
          volumes = [
            "moneymatter-redis-data:/data"
          ];
          extraOptions = [
            "--network=moneymatter"
          ];
        };

        moneymatter-currency = {
          image = "letehaha/currency-rates-api:latest";
          environment = {
            DATABASE_URL = "sqlite:/app/data/currency_rates.db?mode=rwc";
            HOST = "0.0.0.0";
            PORT = "8080";
            DEFAULT_API_BASE = "USD";
            SEED_ON_STARTUP = "true";
            SYNC_ON_STARTUP = "true";
            SYNC_CRON = "0 0 8,12,16,20 * * *";
            RUST_LOG = "currency_rates=info,tower_http=info";
          };
          volumes = [
            "moneymatter-currency-data:/app/data"
          ];
          extraOptions = [
            "--network=moneymatter"
          ];
        };

        moneymatter-be = {
          image = "letehaha/budget-tracker-be:latest";
          environment = {
            IS_SELF_HOST = "true";
            NODE_ENV = "production";
            APPLICATION_PORT = "8081";
            APPLICATION_DB_HOST = "moneymatter-db";
            APPLICATION_DB_PORT = "5432";
            APPLICATION_DB_USER = "budget";
            APPLICATION_DB_USERNAME = "budget";
            APPLICATION_DB_NAME = "budget";
            APPLICATION_DB_DATABASE = "budget";
            APPLICATION_DB_DIALECT = "postgres";
            POSTGRES_USER = "budget";
            POSTGRES_DB = "budget";
            DB_USER = "budget";
            DB_USERNAME = "budget";
            PGHOST = "moneymatter-db";
            PGPORT = "5432";
            PGUSER = "budget";
            PGDATABASE = "budget";
            APPLICATION_REDIS_HOST = "moneymatter-redis";
            CURRENCY_RATES_API_URL = "http://moneymatter-currency:8080";
            BETTER_AUTH_URL = "https://${cfg.domain}";
            AUTH_ORIGIN = "https://${cfg.domain}";
            MCP_BASE_URL = "https://${cfg.domain}";
            OIDC_ISSUER_URL = "https://${config.hannes.services.pocket-id.domain}";
            OIDC_DISCOVERY_URL = "https://${config.hannes.services.pocket-id.domain}/.well-known/openid-configuration";
            DISABLE_PASSWORD_LOGIN = "true";
            ALLOW_SIGNUP = "false";
            AUTO_REDIRECT_OIDC = "true";
          };
          environmentFiles = [
            config.age.secrets.${secretEnv}.path
          ];
          extraOptions = [
            "--network=moneymatter"
          ];
          dependsOn = [
            "moneymatter-db"
            "moneymatter-redis"
            "moneymatter-currency"
          ];
        };

        moneymatter-fe = {
          image = "letehaha/budget-tracker-fe:latest";
          ports = [
            "0.0.0.0:${toString cfg.port}:80"
          ];
          environment = {
            IS_SELF_HOST = "true";
            BACKEND_URL = "http://moneymatter-be:8081";
          };
          extraOptions = [
            "--network=moneymatter"
            "--cap-add=NET_BIND_SERVICE"
          ];
          dependsOn = [
            "moneymatter-be"
          ];
        };
      };
    };
  };
}
