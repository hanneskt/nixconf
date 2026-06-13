{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    rocmOverrideGfx = "10.3.0";
  };

  services.open-webui = {
    enable = true;
    port = 9066;
    host = "100.75.97.2";

    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False";
    };
  };

  # services.caddy = {
  #   enable = true;
  #   virtualHosts."ai.klinckaert.be".extraConfig = ''
  #     reverse_proxy 127.0.0.1:9066
  #   '';
  # };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.config.allowUnfree = true;
  hannes.services = {
    openssh.enable = true;

    # n8n = {
    #   enable = true;
    #   domain = "n8n.puk.local";
    # };
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
