{
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/server/ssh.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  networking.wireless.enable = true;
  hardware.bluetooth.enable = false;

  time.timeZone = "Europe/Brussels";
  users.users.hass.extraGroups = [ "dialout" ];

  # reduce SD writes
  services.journald.storage = "volatile";
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=512M"
      "mode=1777"
      "nosuid"
      "nodev"
    ];
  };
  fileSystems."/var/log" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=128M"
    ];
  };
  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
  ];

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "homeassistant_hardware"
      "airgradient"
      "zha" # zigbee
    ];
    config = {
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "100.106.216.36"
        ];
        server_host = [ "0.0.0.0" ];
      };
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
    };
  };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };
  networking.firewall = {
    allowedTCPPorts = [
      53
      80
    ];
    allowedUDPPorts = [ 53 ];
  };
  security.sudo.wheelNeedsPassword = false;

  services.tailscale.enable = true;

  system.stateVersion = "25.05";
}
