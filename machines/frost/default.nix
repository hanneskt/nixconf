{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/pelican/panel.nix
    ./../../modules/pelican/wings.nix

    ./../../modules/server/homepage.nix
    ./../../modules/server/kuma.nix
    ./../../modules/server/pocket-id.nix
    ./../../modules/server/silverbullet.nix
    ./../../modules/server/ssh.nix
    ./../../modules/server/vikunja.nix
    ./../../modules/server/wakapi.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.forceInstall = true;

  networking = {
    networkmanager.enable = false;
    useDHCP = false;

    defaultGateway = "109.71.252.1";
    interfaces.ens18.ipv4.addresses = [
      {
        address = "109.71.252.201";
        prefixLength = 24;
      }
    ];

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services.tailscale = {
    enable = true;
    disableUpstreamLogging = true;
    permitCertUid = "caddy";
  };

  services.caddy = {
    enable = true;
    virtualHosts."kot.klinckaert.be".extraConfig = ''
      reverse_proxy kotpi:8123
    '';
    virtualHosts."gallery.cruxkraft.eu".extraConfig = ''
      root /var/www/gallery
      file_server
    '';
  };
  age.secrets = {
    "wakapi.env" = {
      file = ../../secrets/wakapi.env.age;
    };
    "silverbullet.env" = {
      file = ../../secrets/silverbullet.env.age;
    };
    "vikunja.env" = {
      file = ../../secrets/vikunja.env.age;
    };
    "homepage.env" = {
      file = ../../secrets/homepage.env.age;
    };
  };

  myServices = {
    pelicanpanel = {
      enable = true;
      domain = "panel.klinckaert.be";
    };
    wings = {
      enable = true;
      domain = "wings.frost.klinckaert.be";
    };
    pocket-id.enable = true;

    wakapi = {
      enable = true;
      envFile = config.age.secrets."wakapi.env".path;
    };
    silverbullet = {
      enable = true;
      envFile = config.age.secrets."silverbullet.env".path;
    };
    vikunja = {
      enable = true;
      envFile = config.age.secrets."vikunja.env".path;
    };
    homepage = {
      enable = true;
      envFile = config.age.secrets."homepage.env".path;
    };
    kuma.enable = true;
  };

  users.users.breakglass = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;
  users.users.hannes.extraGroups = [ "docker" ];

  system.stateVersion = "26.05";
}
