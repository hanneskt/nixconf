{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.silverbullet;
  secretEnv = "silverbullet.env";
in
{
  options.hannes.services.silverbullet = {
    enable = mkEnableOption "Silverbullet";

    domain = mkOption {
      type = types.str;
      default = "notes.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 21072;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    services.silverbullet = {
      enable = true;

      listenPort = cfg.port;
      listenAddress = "127.0.0.1";

      envFile = config.age.secrets.${secretEnv}.path;
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
