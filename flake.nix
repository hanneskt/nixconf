{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    agenix.url = "github:ryantm/agenix";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    betalog-src = {
      url = "github:Topvennie/beta-log";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      nix-index-database,
      nixos-wsl,
      ...
    }@inputs:
    let
      mkMachine =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };

          modules = [
            { networking.hostName = hostname; }
            agenix.nixosModules.default
            nix-index-database.nixosModules.default
            nixos-wsl.nixosModules.default
            ./modules
            ./machines/${hostname}
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
