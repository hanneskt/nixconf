{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.floppy;
  secretEnv = "floppy.env";
in
{
  options.hannes.services.floppy = {
    enable = mkEnableOption "Floppy";

    domain = mkOption {
      type = types.str;
      default = "track.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 10485;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    hannes.reverseProxy.services.floppy = {
      domain = cfg.domain;
      port = cfg.port;
    };

    services.redis.servers.floppy = {
      enable = true;
      port = 6090;
      bind = "0.0.0.0";
      settings = {
        protected-mode = "no";
      };
    };

    networking.firewall.interfaces."podman+".allowedTCPPorts = [ 6090 ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.floppy = {
        image = "ghcr.io/dannyvfilms/floppy:latest";
        ports = [ "0.0.0.0:${toString cfg.port}:8000" ];
        environmentFiles = [ config.age.secrets.${secretEnv}.path ];
        volumes = [
          "floppy-data:/floppy/db"
        ];
        environment = {
          URLS = "https://${cfg.domain}";
          REDIS_URL = "redis://host.containers.internal:6090";
          TZ = config.time.timeZone;
          SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
          SOCIALACCOUNT_ONLY = "True";
          REDIRECT_LOGIN_TO_SSO = "True";
          REGISTRATION = "True";
          DEMO_ACCOUNT_ENABLED = "False";
          ACCOUNT_DEFAULT_HTTP_PROTOCOL = "https";
          USE_X_FORWARDED = "True";
        };
        extraOptions = [
          "--add-host=host.containers.internal:host-gateway"
        ];
      };
    };
  };
}
