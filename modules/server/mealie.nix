{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.mealie;
  secretEnv = "mealie.env";
in
{
  options.hannes.services.mealie = {
    enable = mkEnableOption "Mealie";

    domain = mkOption {
      type = types.str;
      default = "meals.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 9174;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    services.mealie = {
      enable = true;

      port = cfg.port;
      listenAddress = "127.0.0.1";

      credentialsFile = config.age.secrets.${secretEnv}.path;
      settings = {
        ALLOW_SIGNUP = "false";
        ALLOW_PASSWORD_LOGIN = "true";
        OIDC_ADMIN_GROUP = "admin";
        # DEFAULT_GROUP = "";
        # DEFAULT_HOUSEHOLD = "new";
        BASE_URL = "https://${cfg.domain}";
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
