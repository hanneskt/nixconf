{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/pterodactyl/pyropanel.nix
    ./../../modules/pterodactyl/wings.nix
    ./../../modules/server/kuma.nix
    ./../../modules/server/pocket-id.nix
    ./../../modules/server/ssh.nix
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
  };

  services.caddy = {
    enable = true;
    virtualHosts."kot.klinckaert.be".extraConfig = ''
      reverse_proxy kotpi.net:8123
    '';
  };

  myServices.pyropanel = {
    enable = true;
    fqdn = "crux.klinckaert.be";
  };

  myServices.wings = {
    enable = true;
    fqdn = "frost.klinckaert.be";
  };

  age.secrets."pocket-id.env" = {
    file = ../../secrets/pocket-id.env.age;
    owner = "pocket-id";
    group = "pocket-id";
  };

  myServices.pocket-id = {
    enable = true;
    envFile = config.age.secrets."pocket-id.env".path;
  };

  age.secrets."wakapi.env" = {
    file = ../../secrets/wakapi.env.age;
  };
  myServices.wakapi = {
    enable = true;
    envFile = config.age.secrets."wakapi.env".path;
  };
  myServices.kuma.enable = true;

  system.stateVersion = "26.05";
}
