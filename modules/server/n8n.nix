{
  config,
  lib,
  ...
}:

let
  cfg = config.myServices.n8n;
in
{
  options.myServices.n8n = {
    enable = lib.mkEnableOption "n8n";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "n8n.klinckaert.be";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5678;
    };
  };

  config = lib.mkIf cfg.enable {
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
