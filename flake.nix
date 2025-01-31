{
  # Project description
  description = "ETHERNIX";

  # External dependencies
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # NixOS unstable channel
    home-manager = {
      url = "github:nix-community/home-manager";  # Home Manager for user environment management
      inputs.nixpkgs.follows = "nixpkgs";        # Use the same nixpkgs as above
    };
  };

  # System configuration
  outputs = { self, nixpkgs, home-manager, ... }@inputs: rec {
    nixosConfigurations."ethernix" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";  # Target ARM64 architecture
      modules = [
        # Configure cross-compilation settings
        ({ config, pkgs, ... }: {
          nixpkgs.config = {
            allowUnsupportedSystem = true;
            crossSystem = {
              system = "aarch64-linux";
              config = "aarch64-unknown-linux-gnu";
            };
          };
        })
        ./configuration.nix                     # Main system configuration
        home-manager.nixosModules.home-manager # Home Manager integration
        {
          home-manager.useGlobalPkgs = true;    # Use global packages
          home-manager.useUserPackages = true;  # Enable user packages
        }
      ];
    };
  };
}