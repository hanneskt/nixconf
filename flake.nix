{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
      nixpkgs-unstable,
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
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
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
