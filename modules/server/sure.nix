{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.hannes.services.sure;
  secretEnv = "sure.env";
in
{
  options.hannes.services.sure = {
    enable = mkEnableOption "Sure";

    domain = mkOption {
      type = types.str;
      default = "sure.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 18043;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    systemd.services = {
      podman-network-sure_net = {
        path = [ pkgs.podman ];
        script = ''
          podman network exists sure_net || podman network create sure_net
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };

      "podman-sure-db" = {
        requires = [ "podman-network-sure_net.service" ];
        after = [ "podman-network-sure_net.service" ];
      };

      "podman-sure-redis" = {
        requires = [ "podman-network-sure_net.service" ];
        after = [ "podman-network-sure_net.service" ];
      };

      "podman-sure-web" = {
        requires = [ "podman-network-sure_net.service" ];
        after = [
          "podman-network-sure_net.service"
          "podman-sure-db.service"
          "podman-sure-redis.service"
        ];
      };

      "podman-sure-worker" = {
        requires = [ "podman-network-sure_net.service" ];
        after = [
          "podman-network-sure_net.service"
          "podman-sure-db.service"
          "podman-sure-redis.service"
        ];
        serviceConfig.RestartSec = "10s";
      };
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        sure-db = {
          image = "postgres:16";
          environment = {
            POSTGRES_USER = "sure_user";
            POSTGRES_DB = "sure_production";
            POSTGRESS_PASSWORD = "sure_password";
          };
          environmentFiles = [ config.age.secrets.${secretEnv}.path ];
          extraOptions = [ "--network=sure_net" ];
          volumes = [ "sure_postgres-data:/var/lib/postgresql/data" ];
        };

        sure-redis = {
          image = "redis:latest";
          extraOptions = [ "--network=sure_net" ];
          volumes = [ "sure_redis-data:/data" ];
        };

        sure-web = {
          image = "ghcr.io/we-promise/sure:stable";
          environment = {
            DB_HOST = "sure-db";
            DB_PORT = "5432";
            POSTGRES_USER = "sure_user";
            POSTGRES_DB = "sure_production";
            POSTGRESS_PASSWORD = "sure_password";
            REDIS_URL = "redis://sure-redis:6379/1";
            SELF_HOSTED = "true";
            RAILS_FORCE_SSL = "false";
            RAILS_ASSUME_SSL = "true";

            APP_DOMAIN = cfg.domain;
            ONBOARDING_STATE = "closed";

            OIDC_ISSUER = "https://${config.hannes.services.pocket-id.domain}";
            OIDC_REDIRECT_URI = "https://${cfg.domain}/auth/openid_connect/callback";
          };
          environmentFiles = [ config.age.secrets.${secretEnv}.path ];
          ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
          extraOptions = [ "--network=sure_net" ];
          volumes = [ "sure_app-storage:/rails/storage" ];
          dependsOn = [
            "sure-db"
            "sure-redis"
          ];
        };

        sure-worker = {
          image = "ghcr.io/we-promise/sure:stable";
          cmd = [
            "bundle"
            "exec"
            "sidekiq"
          ];
          environment = {
            DB_HOST = "sure-db";
            DB_PORT = "5432";
            POSTGRES_USER = "sure_user";
            POSTGRESS_PASSWORD = "sure_password";
            POSTGRES_DB = "sure_production";
            REDIS_URL = "redis://sure-redis:6379/1";
            SELF_HOSTED = "true";
            RAILS_FORCE_SSL = "false";
            RAILS_ASSUME_SSL = "true";

            APP_DOMAIN = cfg.domain;
          };
          environmentFiles = [ config.age.secrets.${secretEnv}.path ];
          extraOptions = [ "--network=sure_net" ];
          volumes = [ "sure_app-storage:/rails/storage" ];
          dependsOn = [
            "sure-db"
            "sure-redis"
          ];
        };
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
