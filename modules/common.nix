{ pkgs, ... }:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "nl_BE.UTF-8";
      LC_IDENTIFICATION = "nl_BE.UTF-8";
      LC_MEASUREMENT = "nl_BE.UTF-8";
      LC_MONETARY = "nl_BE.UTF-8";
      LC_NAME = "nl_BE.UTF-8";
      LC_NUMERIC = "nl_BE.UTF-8";
      LC_PAPER = "nl_BE.UTF-8";
      LC_TELEPHONE = "nl_BE.UTF-8";
      LC_TIME = "nl_BE.UTF-8";
    };
  };

  nix.settings.trusted-users = [
    "root"
    "hannes"
  ];
  users.users.hannes = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf" # tatsu
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKk+wKeV03SaP4fJtPJ31P/cpwFi0ZzQeyit6kLgnQHA" # arrax
    ];
  };

  programs.fish.enable = true;
  documentation.man.generateCaches = false;

  environment.systemPackages = with pkgs; [
    helix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
