{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
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
    openFirewall = true;

    virtualHosts = {
      "gallery.cruxkraft.eu".extraConfig = ''
        root /var/www/gallery
        file_server
      '';
    };
  };

  # proxies services on other hosts through here
  hannes.reverseProxy.isProxy = true;

  hannes.services = {
    openssh.enable = true;

    gatus.enable = true;

    pelicanpanel.enable = true;
    wings.enable = true;

    pocket-id.enable = true;

    silverbullet.enable = true;
    vikunja.enable = true;
    wakapi.enable = true;

    mealie.enable = true;

    betalog.enable = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
  ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "26.05";
}
