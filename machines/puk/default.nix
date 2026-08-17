{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    supportedFilesystems = [ "bcachefs" ];
    initrd.kernelModules = [ "amdgpu" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "10.3.0";
      host = "0.0.0.0";
    };

    open-webui = {
      enable = true;
      port = 9066;
      host = "0.0.0.0";

      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
        WEBUI_AUTH = "False";
      };
    };

    tailscale = {
      enable = true;
      disableUpstreamLogging = true;
    };
  };

  fileSystems."/mnt/storage" = {
    device = "UUID=17795ea9-d422-4e2d-8ace-4c3281cce0a9";
    fsType = "bcachefs";
    options = [
      "nofail"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  hannes.services = {
    openssh.enable = true;
    paperless.enable = true;
    dawarich.enable = true;
    sure.enable = true;
    floppy.enable = true;
    immich.enable = true;
  };
  environment.systemPackages = [ pkgs.bcachefs-tools ];

  networking.firewall.allowedTCPPorts = [
    80
    443
    config.hannes.services.immich.port
  ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
