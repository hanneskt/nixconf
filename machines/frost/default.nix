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
      allowedTCPPorts = [ 80 443 2022 ];
      allowedTCPPortRanges = [ { from = 25000; to = 26000; } ];
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
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.wings = {
    image = "ghcr.io/pterodactyl/wings:v1.12.1";
    autoStart = true;

    ports = [
      "127.0.0.1:9000:443" # API
      "0.0.0.0:2022:2022"  # SFTP
    ];

    volumes = [
      "/var/lib/pterodactyl/config.yml:/etc/pterodactyl/config.yml"
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/pterodactyl/volumes:/var/lib/pterodactyl/volumes"
      "/var/lib/pterodactyl/backups:/var/lib/pterodactyl/backups"
    ];
  };

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
