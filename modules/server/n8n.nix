{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.n8n;
in
{
  options.hannes.services.n8n = {
    enable = mkEnableOption "n8n";

    domain = mkOption {
      type = types.str;
      default = "n8n.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 5678;
    };
  };

  config = mkIf cfg.enable {
    services.n8n = {
      enable = true;

      environment = {
        N8N_PORT = cfg.port;
        WEBHOOK_URL = "https://${cfg.domain}";
        N8N_HOST = cfg.domain;
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
