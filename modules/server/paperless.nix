{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.paperless;
  secretEnv = "paperless.env";
in
{
  options.hannes.services.paperless = {
    enable = mkEnableOption "Paperless-ngx";

    domain = mkOption {
      type = types.str;
      default = "paper.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 28981;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    hannes.reverseProxy.services.paperless = {
      domain = cfg.domain;
      port = cfg.port;
    };

    services.paperless = {
      enable = true;

      port = cfg.port;
      address = "0.0.0.0";

      environmentFile = config.age.secrets.${secretEnv}.path;

      settings = {
        PAPERLESS_URL = "https://${cfg.domain}";
        PAPERLESS_OCR_LANGUAGE = "nld+eng";
        PAPERLESS_TIME_ZONE = "Europe/Brussels";
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = true;
        PAPERLESS_DISABLE_REGULAR_LOGIN = true;
        PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
      };
    };
  };
}
