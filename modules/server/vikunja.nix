{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.vikunja;
  secretEnv = "vikunja.env";
in
{
  options.hannes.services.vikunja = {
    enable = mkEnableOption "Vikunja";

    domain = mkOption {
      type = types.str;
      default = "todo.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 21071;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    hannes.reverseProxy.services.vikunja = {
      domain = cfg.domain;
      port = cfg.port;
    };

    services.vikunja = {
      enable = true;
      environmentFiles = [ config.age.secrets.${secretEnv}.path ];

      frontendScheme = "https";
      frontendHostname = cfg.domain;

      port = cfg.port;

      settings = {
        service = {
          enableregistration = false;
        };
      };
    };
  };
}
