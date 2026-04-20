{
  config,
  lib,
  ...
}:

let
  cfg = config.myServices.pocket-id;
in
{
  options.myServices.pocket-id = {
    enable = lib.mkEnableOption "Pocket ID wrapper";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "auth.klinckaert.be";
    };

    envFile = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      environmentFile = cfg.envFile;
      settings = {
        APP_URL = "https://${cfg.domain}";
        PORT = "21068";
        HOST = "127.0.0.1";
        TRUST_PROXY = true;
        ANALYTICS_DISABLED = true;
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:21068
      '';
    };
  };
}
