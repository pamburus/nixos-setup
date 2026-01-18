{
  description = "NixOS system configuration with Home Manager using Flakes";

  inputs = {
    # Nixpkgs: Main package repository
    # Using nixos-25.11 branch for stability
    # Change to nixos-unstable for latest packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager: User environment configuration
    # Must match nixpkgs version for compatibility
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # This ensures home-manager uses the same nixpkgs version as NixOS
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom tools
    hl = {
      url = "github:pamburus/hl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    termframe = {
      url = "github:pamburus/termframe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hl, termframe }:
    let
      # System type - set to your actual system
      # Options: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin
      system = "aarch64-linux";

      # Access to nixpkgs packages for this system
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Define your NixOS configurations here
      # Format: nixosConfigurations.<hostname> = <configuration>
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        # Allow modules to access the flake itself and custom tools
        specialArgs = {
          inherit self hl termframe;
          flakePath = self;
        };

        # Modules to include in this configuration
        modules = [
          # Your main system configuration
          "${self}/configuration.nix"

          # Home Manager NixOS integration
          home-manager.nixosModules.home-manager

          # Home Manager global settings
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit self; };
          }
        ];
      };

      # Optional: Add more configurations for different machines
      # Example:
      # nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      #   inherit system;
      #   modules = [ "${self}/hosts/laptop/configuration.nix" ];
      # };
    };
}
