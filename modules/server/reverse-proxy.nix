{
  inputs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.hannes.reverseProxy;

  serviceType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "reverse-proxy this service";
      };

      domain = mkOption {
        type = types.str;
        description = "full domain name to revprox";
      };

      port = mkOption {
        type = types.port;
        description = "the port of the service which caddy connects to";
      };

      host = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "null = auto: proxy machine or tailscale hostname";
      };

      status = mkOption {
        type = types.bool;
        default = true;
        description = "Show on status page";
      };
    };
  };

  endpoints = flatten (
    mapAttrsToList (
      machineName: sys:
      mapAttrsToList (svcName: svc: {
        inherit machineName svc;
        name = svcName;
      }) sys.config.hannes.reverseProxy.services
    ) inputs.self.nixosConfigurations
  );

  upstream =
    e:
    if e.svc.host != null then
      e.svc.host
    else if e.machineName == config.networking.hostName then
      "127.0.0.1"
    else
      e.machineName;
in
{
  options.hannes.reverseProxy = {
    isProxy = mkEnableOption "serve all revprox services on this machine";

    services = mkOption {
      type = types.attrsOf serviceType;
      default = { };
      description = "which services to revprox";
    };

    endpoints = mkOption {
      type = types.listOf types.attrs;
      internal = true;
      description = "revprox entries for every machine";
    };
  };

  config = mkMerge [
    { hannes.reverseProxy.endpoints = endpoints; }

    (mkIf cfg.isProxy {
      services.caddy = {
        enable = true;
        virtualHosts = listToAttrs (
          map (e: {
            name = e.svc.domain;
            value.extraConfig = ''
              reverse_proxy ${upstream e}:${toString e.svc.port}
            '';
          }) (filter (e: e.svc.enable) endpoints)
        );
      };
    })
  ];
}
