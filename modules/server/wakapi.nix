{ config, lib, ... }:

with lib;
let
  cfg = config.myServices.wakapi;
in
{
  options.myServices.wakapi = {
    enable = mkEnableOption "Wakapi";
    domain = mkOption {
      type = types.str;
      default = "waka.klinckaert.be";
    };
    envFile = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    services.wakapi = {
      enable = true;
      database.dialect = "sqlite3";
      passwordSalt = "wakapi";
      settings = {
        server = {
          public_url = "https://${cfg.domain}";
          port = 9090;
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

    systemd.services.wakapi = lib.mkIf (cfg.envFile != "") {
      serviceConfig.EnvironmentFile = [ cfg.envFile ];
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:9090
      '';
    };
  };
}
