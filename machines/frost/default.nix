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
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no"; # for root
    settings.PasswordAuthentication = false; # for other users
    openFirewall = true;
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "26.05";
}
