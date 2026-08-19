{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.dawarich;
  secretEnv = "dawarich.env";
in
{
  options.hannes.services.dawarich = {
    enable = mkEnableOption "Dawarich";

    domain = mkOption {
      type = types.str;
      default = "timeline.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 48204;
    };

  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    hannes.reverseProxy.services.dawarich = {
      domain = cfg.domain;
      port = cfg.port;
    };

    services.dawarich = {
      enable = true;

      localDomain = cfg.domain;
      webPort = cfg.port;
      configureNginx = false;
      extraEnvFiles = [ config.age.secrets.${secretEnv}.path ];

      environment = {
        OIDC_ISSUER = "https://${config.hannes.services.pocket-id.domain}";
        OIDC_REDIRECT_URI = "https://${cfg.domain}/users/auth/openid_connect/callback";
        OIDC_PROVIDER_NAME = "hannes";
        OIDC_AUTO_REGISTER = "true";
        ALLOW_EMAIL_PASSWORD_REGISTRATION = "false";
        ALLOW_EMAIL_PASSWORD_LOGIN = "false";
        OIDC_PKCE_ENABLED = "true";
        PLACE_VISITS_THROTTLE_SECONDS = "0.1";
      };
    };
  };
}
