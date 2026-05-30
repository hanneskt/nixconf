{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.myServices.vikunja;
in
{
  options.myServices.vikunja = {
    enable = mkEnableOption "Vikunja";

    domain = mkOption {
      type = types.str;
      default = "todo.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 21071;
    };

    envFile = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vikunja = {
      enable = true;

      frontendScheme = "https";
      frontendHostname = cfg.domain;

      port = cfg.port;

      settings = {
        service = {
          enableregistration = false;
        };
      };

      environmentFiles = lib.optional (cfg.envFile != "") cfg.envFile;
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
