{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.gatus;

  monitored = filter (e: e.svc.enable && e.svc.status) config.hannes.reverseProxy.endpoints;

  groupedEndpoints = map (e: {
    name = e.svc.domain;
    group = e.machineName;
    url = "https://${e.svc.domain}";
    interval = "5m";
    conditions = [ "[STATUS] == any(200, 401)" ];
  }) monitored;
in
{
  options.hannes.services.gatus = {
    enable = mkEnableOption "gatus";

    domain = mkOption {
      type = types.str;
      default = "frost.tabby-wall.ts.net";
    };

    port = mkOption {
      type = types.port;
      default = 35296;
    };
  };

  config = mkIf cfg.enable {
    services.gatus = {
      enable = true;
      settings = {
        web.port = cfg.port;
        endpoints = groupedEndpoints;
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts.${cfg.domain}.extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
