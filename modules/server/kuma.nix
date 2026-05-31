{ config, lib, ... }:

with lib;
let
  cfg = config.hannes.services.kuma;
in
{
  options.hannes.services.kuma = {
    enable = mkEnableOption "Uptime Kuma";

    port = mkOption {
      type = types.port;
      default = 21067;
    };
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = toString cfg.port;
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."uptime.klinckaert.be".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
