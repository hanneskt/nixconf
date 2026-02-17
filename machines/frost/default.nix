{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.forceInstall = true;

  networking.hostName = "frost";

  networking = {
    networkmanager.enable = false;
    useDHCP = false;

    defaultGateway = "109.71.252.1";
    interfaces.ens18.ipv4.addresses = [{
      address = "109.71.252.201";
      prefixLength = 24;
    }];
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    firewall = {
      enable = true;
      trustedInterfaces = [ "pterodactyl0" ];
      allowedTCPPorts = [ 80 443 2022 ];
      allowedTCPPortRanges = [ { from = 25000; to = 26000; } ];
      allowedUDPPortRanges = [ { from = 25000; to = 26000; } ];
    };
  };

  nix.settings.trusted-users = [ "root" "hannes" ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no"; # for root
    settings.PasswordAuthentication = false; # for other users
    openFirewall = true;
  };

  security.sudo.wheelNeedsPassword = false;
  users.users.hannes.extraGroups = [ "docker" ];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  systemd.services.init-pterodactyl-network = {
      description = "Create Docker network for Pterodactyl";
      after = [ "network.target" "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect pterodactyl-net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create pterodactyl-net
      '';
    };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      database = {
        image = "mariadb:10.5";
        extraOptions = [ "--network=pterodactyl-net" ];
        environment = {
          MYSQL_DATABASE = "panel";
          MYSQL_USER = "pterodactyl";
        };
        environmentFiles = [ "/var/lib/pterodactyl/panel.env" ];
        volumes = [ "/var/lib/pterodactyl/database:/var/lib/mysql" ];
        cmd = [ "--default-authentication-plugin=mysql_native_password" ];
      };

      cache = {
        image = "redis:alpine";
        extraOptions = [ "--network=pterodactyl-net" ];
      };

      panel = {
        image = "ghcr.io/pyrodactyl-oss/pyrodactyl:v5.0.1";
        extraOptions = [ "--network=pterodactyl-net" ];
        ports = [ "127.0.0.1:8000:80" ];
        environment = {
          APP_ENV = "production";
          APP_ENVIRONMENT_ONLY = "false";
          APP_TIMEZONE = "UTC";

          DB_CONNECTION = "mariadb";
          DB_HOST = "database";
          DB_PORT = "3306";
          DB_USERNAME = "pterodactyl";

          CACHE_DRIVER = "redis";
          SESSION_DRIVER = "redis";
          QUEUE_DRIVER = "redis";
          REDIS_HOST = "cache";

          TRUSTED_PROXIES = "*";

          MAIL_DRIVER = "log";
        };
        environmentFiles = [ "/var/lib/pterodactyl/panel.env" ];
        volumes = [
          "/var/lib/pterodactyl/var/:/app/var/"
          "/var/lib/pterodactyl/nginx/:/etc/nginx/http.d/"
          "/var/lib/pterodactyl/certs/:/etc/letsencrypt/"
          "/var/lib/pterodactyl/logs/:/app/storage/logs"
        ];
        dependsOn = [ "database" "cache" ];
      };
    };
  };

  virtualisation.oci-containers.containers.wings = {
    image = "ghcr.io/pterodactyl/wings:v1.12.1";

    ports = [
      "127.0.0.1:9000:443" # API
      "0.0.0.0:2022:2022"  # SFTP
    ];

    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/run/wings:/run/wings"
      "/tmp/pterodactyl:/tmp/pterodactyl"

      "/var/lib/pterodactyl/config.yml:/etc/pterodactyl/config.yml"

      "/var/lib/pterodactyl/volumes:/var/lib/pterodactyl/volumes"
      "/var/lib/pterodactyl/backups:/var/lib/pterodactyl/backups"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /run/wings 0755 root root -"
  ];

  services.caddy = {
    enable = true;
    virtualHosts."crux.klinckaert.be".extraConfig = ''
      reverse_proxy 127.0.0.1:8000
    '';
    virtualHosts."frost.klinckaert.be".extraConfig = ''
      reverse_proxy 127.0.0.1:9000
    '';
  };

  system.stateVersion = "26.05";
}
