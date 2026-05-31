{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.pelicanpanel;
in
{
  options.hannes.services.pelicanpanel = {
    enable = mkEnableOption "Pelican Panel";

    domain = mkOption {
      type = types.str;
      default = "panel.cruxkraft.eu";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:8000
      '';
    };

    virtualisation.docker.enable = true;

    systemd.tmpfiles.rules = [
      "d /var/lib/pelican/data 0777 root root -"
      "d /var/lib/pelican/logs 0777 root root -"
    ];

    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers.pelican-panel = {
      image = "ghcr.io/pelican-dev/panel:latest";
      ports = [ "127.0.0.1:8000:80" ];
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      environment = {
        APP_URL = "https://${cfg.domain}";
        APP_ENV = "production";
        APP_DEBUG = "false";

        APP_INSTALLED = "true";

        BEHIND_PROXY = "true";
        TRUSTED_PROXIES = "127.0.0.1";

        XDG_DATA_HOME = "/pelican-data";
      };
      volumes = [
        "/var/lib/pelican/data:/pelican-data"
        "/var/lib/pelican/logs:/var/www/html/storage/logs"
      ];
    };
  };
}
