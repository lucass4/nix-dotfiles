{
  description = "Home Manager configuration of Lucas Santanna";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    helix-themes = {
      url = "github:eureka-cpu/helix-themes.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, ... }:
    let
      lib = nixpkgs.lib;

      # Define hosts and their systems
      hosts = {
        "lucass-MacBook-Pro" = "x86_64-darwin";
        "fg-lstanaanna" = "aarch64-darwin";
      };

      # Common modules for all systems
      commonModules = [
        ./modules/darwin
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.lucas.imports = [ ./modules/home-manager ];
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];

      systems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      # Generate darwinConfigurations from hosts
      darwinConfigurations = lib.mapAttrs (hostName: system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules;
        }) hosts;

      legacyPackages = forAllSystems (system:
        import nixpkgs {
          inherit system;
        });
    };
}
