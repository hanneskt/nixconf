{ lib, config, ... }:
with lib;
let
  cfg = config.hannes.services.openssh;
in
{
  options.hannes.services.openssh = {
    enable = mkEnableOption "openssh server";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no"; # for root
      settings.PasswordAuthentication = false; # for other users
      openFirewall = true;
      extraConfig = ''
        # if there is an emergency user configured, don't allow it ssh access
        DenyUsers breakglass
      '';
    };

    networking.firewall.logRefusedConnections = false;
    services.fail2ban = {
      enable = true;
      bantime = "12h";
      maxretry = 2;
      ignoreIP = [
        "127.0.0.0/8"
        "100.64.0.0/10"
      ];
    };
  };
}
