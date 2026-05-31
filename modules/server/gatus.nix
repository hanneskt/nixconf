{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.services.gatus;

  allMachines = inputs.self.nixosConfigurations;
  domainsByMachine = lib.mapAttrs (
    machineName: sys:
    if sys.config.services.caddy.enable then
      let
        ignoredSuffixes = [
          ".local"
          ".ts.net"
        ];
        isIgnored = domain: lib.any (suffix: lib.hasSuffix suffix domain) ignoredSuffixes;
      in
      lib.filter (domain: !isIgnored domain) (builtins.attrNames sys.config.services.caddy.virtualHosts)
    else
      [ ]
  ) allMachines;

  groupedEndpoints = lib.flatten (
    lib.mapAttrsToList (
      machineName: domains:
      map (domain: {
        name = domain;
        group = machineName;
        url = "https://${domain}";
        interval = "1m";
        conditions = [ "[STATUS] == any(200, 401)" ];
      }) domains
    ) domainsByMachine
  );
in
{
  options.hannes.services.gatus = {
    enable = mkEnableOption "gatus";

    domain = mkOption {
      type = types.str;
      default = "frost.tabby-wall.ts.net";
    };

    port = mkOption {
      type = types.port;
      default = 35296;
    };
  };

  config = mkIf cfg.enable {
    services.gatus = {
      enable = true;
      settings = {
        web.port = cfg.port;
        endpoints = groupedEndpoints;
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts.${cfg.domain}.extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
