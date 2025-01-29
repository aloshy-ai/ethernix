{
  description = "ETHERNIX";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: rec {
    nixosConfigurations."ethernix" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ({ config, pkgs, ... }: {
          nixpkgs.config = {
            allowUnsupportedSystem = true;
            crossSystem = {
              system = "aarch64-linux";
              config = "aarch64-unknown-linux-gnu";
            };
          };
        })
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
  };
}