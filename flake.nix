# flake.nix

{
  description = "ETHERNIX";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: rec {
  
    # here goes the other flake outputs, if you have any

    nixosConfigurations."ethernix" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
