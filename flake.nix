{
  description = "Lucas Santanna's Nix-Darwin and Home Manager Configuration";

  inputs = {
    # Nixpkgs - primary package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager - dotfile and user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Darwin - macOS system configuration
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helix editor themes
    helix-themes = {
      url = "github:eureka-cpu/helix-themes.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, ... }:
    let
      inherit (nixpkgs) lib;

      # Supported systems
      systems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = lib.genAttrs systems;

      # Define hosts and their architectures
      hosts = {
        "lucass-MacBook-Pro" = "x86_64-darwin";
        "fg-lstanaanna" = "aarch64-darwin";
      };

      # Common modules shared across all Darwin configurations
      commonModules = [
        ./modules/darwin
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.lucas.imports = [ ./modules/home-manager ];
            extraSpecialArgs = { inherit inputs; };
          };
        }
      ];

      # Helper to get pkgs for a given system
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Darwin system configurations
      darwinConfigurations = lib.mapAttrs
        (hostName: system:
          darwin.lib.darwinSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = commonModules;
          })
        hosts;

      # Formatter for `nix fmt`
      formatter = forAllSystems (system:
        (pkgsFor system).nixpkgs-fmt
      );

      # Development shells
      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            name = "dotfiles-dev";
            packages = with pkgs; [
              nixpkgs-fmt
              nil # Nix LSP
              statix # Nix linter
              deadnix # Find dead Nix code
            ];
            shellHook = ''
              echo "🏠 Dotfiles development environment"
              echo "Available commands:"
              echo "  nix fmt                    - Format Nix files"
              echo "  statix check .             - Lint Nix files"
              echo "  deadnix .                  - Find unused Nix code"
              echo "  darwin-rebuild switch --flake .#\$(hostname -s)"
            '';
          };
        }
      );

      # Validation checks for CI/pre-commit
      checks = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          # Check that all Nix files are formatted
          formatting = pkgs.runCommand "check-formatting"
            { buildInputs = [ pkgs.nixpkgs-fmt ]; }
            ''
              cd ${./.}
              nixpkgs-fmt --check .
              touch $out
            '';

          # Static analysis of Nix files
          statix-check = pkgs.runCommand "statix-check"
            { buildInputs = [ pkgs.statix ]; }
            ''
              cd ${./.}
              statix check .
              touch $out
            '';
        }
      );

      # Legacy packages for compatibility
      legacyPackages = forAllSystems (system: pkgsFor system);
    };
}
