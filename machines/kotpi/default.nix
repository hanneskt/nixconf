{
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  networking.wireless.enable = false;
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

  hannes.services.openssh.enable = true;

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "homeassistant_hardware"
      "airgradient"
      "zha" # zigbee
      "mqtt"
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
    openFirewall = false;
    host = "127.0.0.1";
    port = 3000;

    settings = {
      querylog.dir_path = "/run/AdGuardHome";
      statistics.dir_path = "/run/AdGuardHome";
    };
  };

  services.caddy = {
    enable = true;
    openFirewall = true;
    virtualHosts."dns.kotpi.local" = {
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "0.0.0.0";
        port = 1883;
        users = {
          homeassistant = {
            hashedPassword = "$7$101$rqDs+TeiPsT3b5Z0$VqqCaVCcNgTP7hfBVQbBNww5dFUiKso0lafP1YvFX7ltHECvXwhCauS5wZI5YAg8TrtLWDgpnGQuzXn7PngJLQ==";
            acl = [ "readwrite #" ];
          };
          awtrix = {
            hashedPassword = "$7$101$rgw1NmLB8MhDCZQX$NYYSYjPBaYXxc2hudF1OoyiGt5zgj5HTxmis4QjmujzpmJQ5SD+X3SorOdBPmhSjOD6Olybk/UGd25wE7AChzg==";
            acl = [
              "readwrite awtrix/#"
              "readwrite homeassistant/#"
            ];
          };
        };
      }
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      53 # adguard
      1883 # mosquitto
    ];
    allowedUDPPorts = [ 53 ]; # adguard
  };
  security.sudo.wheelNeedsPassword = false;

  services.tailscale.enable = true;

  system.stateVersion = "25.05";
}
