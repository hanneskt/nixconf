{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.immich;
  secretOauth = "immich-oauth-secret";
in
{
  options.hannes.services.immich = {
    enable = mkEnableOption "Immich";

    domain = mkOption {
      type = types.str;
      default = "photos.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 11480;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretOauth}.file = "${inputs.self}/secrets/${secretOauth}.age";

    services.immich = {
      enable = true;

      port = cfg.port;
      host = "0.0.0.0";
      mediaLocation = "/mnt/storage/immich";

      settings = {
        server.externalDomain = "https://${cfg.domain}";

        passwordLogin.enabled = false;

        oauth = {
          enabled = true;
          issuerUrl = "https://${config.hannes.services.pocket-id.domain}";
          clientId = "7b5094da-1488-4dc0-b76f-e99905aab7c0";
          clientSecret._secret = config.age.secrets.${secretOauth}.path;
          autoLaunch = true;
          buttonText = "Login with PocketID";
          roleClaim = "groups";
        };
      };
    };
  };
}
