{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
  ];
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ]; # allow binary emulation for aarch64

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "bcachefs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ ];

      # set incoming packages time to live to 64
      # this fixes container networking for networks who stop re-routing by setting TTL to 1
      extraCommands = ''
        iptables -t mangle -I PREROUTING 1 -i wlp0s20f3 -j TTL --ttl-set 64
      '';
    };

    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

  };

  hardware.bluetooth.enable = true;

  security.sudo.extraConfig = "Defaults insults, pwfeedback";
  users.users.hannes = {
    extraGroups = [
      "input"
      "wireshark"
      "dialout"
      "docker"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  virtualisation = {
    podman.enable = true;
    docker = {
      enable = true;
      daemon.settings = {
        bip = "172.30.0.1/24";
        default-address-pools = [
          {
            base = "172.31.0.0/16";
            size = 24;
          }
        ];
      };
    };
  };

  programs = {
    nix-ld.enable = true;
    niri.enable = true;
    fish.enable = true;
    steam.enable = true;
    wireshark.enable = true;
    nix-index-database.comma.enable = true;
  };

  services = {
    tailscale.enable = true;
    printing.enable = true;
    avahi = {
      enable = false;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "24.05";
}
