{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.wakapi;
  secretEnv = "wakapi.env";
in
{
  options.hannes.services.wakapi = {
    enable = mkEnableOption "Wakapi";

    domain = mkOption {
      type = types.str;
      default = "waka.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 9090;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    hannes.reverseProxy.services.wakapi = {
      domain = cfg.domain;
      port = cfg.port;
    };

    services.wakapi = {
      enable = true;
      environmentFiles = [ config.age.secrets.${secretEnv}.path ];

      database.dialect = "sqlite3";

      settings = {
        server = {
          public_url = "https://${cfg.domain}";
          port = cfg.port;
        };
        app = {
          leaderboard_enabled = false;
        };
        security = {
          allow_signup = false;
          disable_local_auth = true;
          disable_webauthn = true;
          disable_frontpage = true;
          insecure_cookies = false;
          oidc_allow_signup = false;
        };
      };
    };
  };
}
