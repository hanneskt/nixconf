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
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            { networking.hostName = hostname; }
            agenix.nixosModules.default
            nix-index-database.nixosModules.default
            ./modules/common.nix
            ./machines/${hostname}/default.nix
          ];
        };

      # get machines by from the machines directory
      machineContents = builtins.readDir ./machines;
      machineDirs = nixpkgs.lib.filterAttrs (name: type: type == "directory") machineContents;
      hosts = builtins.attrNames machineDirs;
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts mkMachine;
    };
}
