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
    hannes.reverseProxy.services.kuma = {
      domain = "uptime.klinckaert.be";
      port = cfg.port;
    };

    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = toString cfg.port;
      };
    };
  };
}
