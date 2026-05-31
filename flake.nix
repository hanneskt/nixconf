{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    agenix.url = "github:ryantm/agenix";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      nix-index-database,
      ...
    }@inputs:
    let
      mkMachine =
        {
          hostname,
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            { networking.hostName = hostname; }
            agenix.nixosModules.default
            ./modules/common.nix
            ./machines/${hostname}/default.nix
            nix-index-database.nixosModules.default
          ];
        };
    in
    {
      nixosConfigurations = {
        frost = mkMachine { hostname = "frost"; };
        puk = mkMachine { hostname = "puk"; };
        tatsu = mkMachine { hostname = "tatsu"; };

        kotpi = mkMachine {
          hostname = "kotpi";
          system = "aarch64-linux";
        };
      };
    };
}
