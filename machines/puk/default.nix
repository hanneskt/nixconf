{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.config.allowUnfree = true;
  hannes.services = {
    openssh.enable = true;

    n8n = {
      enable = true;
      domain = "n8n.puk.local";
    };
  };

  services.tailscale = {
    enable = true;
    disableUpstreamLogging = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
