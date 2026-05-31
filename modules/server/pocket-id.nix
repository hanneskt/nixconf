{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.myServices.pocket-id;
in
{
  options.myServices.pocket-id = {
    enable = lib.mkEnableOption "Pocket ID";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "auth.klinckaert.be";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."pocket-id.env" = {
      file = "${inputs.self}/secrets/pocket-id.env.age";
      owner = "pocket-id";
      group = "pocket-id";
    };

    services.pocket-id = {
      enable = true;
      environmentFile = config.age.secrets."pocket-id.env".path;
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
