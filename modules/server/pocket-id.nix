{
  config,
  lib,
  inputs,
  ...
}:

with lib;
let
  cfg = config.hannes.services.pocket-id;
  secretEnv = "pocket-id.env";
in
{
  options.hannes.services.pocket-id = {
    enable = mkEnableOption "Pocket ID";

    domain = mkOption {
      type = types.str;
      default = "auth.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 21068;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv} = {
      file = "${inputs.self}/secrets/${secretEnv}.age";
      owner = "pocket-id";
      group = "pocket-id";
    };

    hannes.reverseProxy.services.pocket-id = {
      domain = cfg.domain;
      port = cfg.port;
    };

    services.pocket-id = {
      enable = true;
      environmentFile = config.age.secrets.${secretEnv}.path;

      settings = {
        APP_URL = "https://${cfg.domain}";
        PORT = cfg.port;
        HOST = "127.0.0.1";
        TRUST_PROXY = true;
        ANALYTICS_DISABLED = true;
      };
    };
  };
}
