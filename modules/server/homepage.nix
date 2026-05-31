{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.homepage;
  secretEnv = "homepage.env";
in
{
  options.hannes.services.homepage = {
    enable = mkEnableOption "Homepage Dashboard";

    domain = mkOption {
      type = types.str;
      default = "home.klinckaert.be";
    };

    port = mkOption {
      type = types.port;
      default = 8082;
    };
  };

  config = mkIf cfg.enable {
    age.secrets.${secretEnv}.file = "${inputs.self}/secrets/${secretEnv}.age";

    services.homepage-dashboard = {
      enable = true;
      environmentFiles = [ config.age.secrets.${secretEnv}.path ];

      listenPort = cfg.port;

      settings = {
        title = "Server Dashboard";
        theme = "dark";
        color = "slate";
        layout = {
          "Infrastructure" = {
            style = "row";
            columns = 4;
          };
        };
      };

      services = [
        {
          "Apps" = [
            {
              "Vikunja" = {
                icon = "vikunja";
                href = "https://todo.klinckaert.be";
                widget = {
                  type = "vikunja";
                  url = "https://todo.klinckaert.be";
                  key = "{{HOMEPAGE_VAR_VIKUNJA_TOKEN}}";
                  enableTaskList = true;
                  version = 2;
                };
              };
            }
            {
              "Pocket ID" = {
                icon = "pocket-id";
                href = "https://auth.klinckaert.be";
              };
            }
          ];
          "Crux" = [
            {
              "Survival" = {
                icon = "minecraft-creeper";
                href = "http://213.170.135.41:25663/";
                widget = {
                  type = "minecraft";
                  url = "udp://213.170.135.41:25667";
                };
              };
              "Creative" = {
                icon = "minecraft-creeper";
                widget = {
                  type = "minecraft";
                  url = "udp://109.71.252.201:25565";
                };
              };
            }
          ];
        }
      ];

      bookmarks = [
        {
          "Dev" = [
            {
              "NixOS Options" = {
                abbr = "NX";
                href = "https://search.nixos.org/options";
              };
            }
          ];
        }
      ];
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
