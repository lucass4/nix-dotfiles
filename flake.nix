{
  description = "Lucas Santanna's Nix-Darwin and Home Manager Configuration";

  inputs = {
    # Nixpkgs - primary package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Systems - standard system definitions
    systems.url = "github:nix-systems/default";

    # Flake-parts - modular flake framework
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

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

  outputs = inputs@{ self, flake-parts, systems, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Import systems from the systems input
      systems = import systems;

      # Flake-wide configuration
      flake = {
        # Darwin system configurations
        darwinConfigurations =
          let
            inherit (inputs.nixpkgs) lib;

            # Define hosts and their architectures
            hosts = {
              "lucass-MacBook-Pro" = {
                system = "x86_64-darwin";
                username = "lucas";
              };
              "fg-lstanaanna" = {
                system = "aarch64-darwin";
                username = "lucas";
              };
            };

            mkDarwinSystem = hostName: { system, username }:
              let
                # Check if host-specific config exists
                hostConfigPath = ./hosts + "/${hostName}.nix";
                hasHostConfig = builtins.pathExists hostConfigPath;
              in
              inputs.darwin.lib.darwinSystem {
                inherit system;

                specialArgs = {
                  inherit inputs hostName username;
                  inherit (self) outputs;
                };

                modules = [
                  # Core Darwin configuration
                  ./modules/darwin

                  # Home Manager integration
                  inputs.home-manager.darwinModules.home-manager
                  {
                    home-manager = {
                      useGlobalPkgs = true;
                      useUserPackages = true;

                      users.${username} = {
                        imports = [ ./modules/home ];
                      };

                      extraSpecialArgs = {
                        inherit inputs hostName username;
                        inherit (self) outputs;
                      };

                      # Enable verbose mode for debugging
                      verbose = true;
                    };
                  }
                ]
                # Conditionally add host-specific configuration
                ++ lib.optional hasHostConfig hostConfigPath;
              };
          in
          lib.mapAttrs mkDarwinSystem hosts;
      };

      # Per-system configuration
      perSystem = { pkgs, system, ... }: {
        # Custom package set configuration
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            # Custom overlays can be added here
            self.overlays.default or (_: _: { })
          ];
        };

        # Formatter for `nix fmt`
        formatter = pkgs.nixpkgs-fmt;

        # Development shells
        devShells = {
          default = pkgs.mkShell {
            name = "dotfiles-dev";

            packages = with pkgs; [
              # Nix tooling
              nixpkgs-fmt
              nil # Nix LSP
              nixd # Alternative Nix LSP
              statix # Nix linter
              deadnix # Find dead Nix code

              # Utilities
              git
              just # Command runner
            ];

            shellHook = ''
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "🏠 Dotfiles Development Environment"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo ""
              echo "📦 Available commands:"
              echo "  nix fmt                    Format Nix files"
              echo "  nix flake check            Run all checks"
              echo "  nix flake show             Show flake outputs"
              echo "  statix check .             Lint Nix files"
              echo "  deadnix .                  Find unused Nix code"
              echo ""
              echo "🖥️  System management:"
              echo "  darwin-rebuild switch --flake .#\$(hostname -s)"
              echo "  darwin-rebuild build --flake .#\$(hostname -s)"
              echo ""
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            '';
          };
        };

        # Validation checks for CI/pre-commit
        checks = {
          # Check that all Nix files are formatted
          formatting = pkgs.runCommand "check-formatting"
            {
              buildInputs = [ pkgs.nixpkgs-fmt ];
            }
            ''
              cd ${self}
              nixpkgs-fmt --check .
              touch $out
            '';

          # Static analysis of Nix files
          statix = pkgs.runCommand "statix-check"
            {
              buildInputs = [ pkgs.statix ];
            }
            ''
              cd ${self}
              statix check .
              touch $out
            '';

          # Find dead/unused Nix code
          deadnix = pkgs.runCommand "deadnix-check"
            {
              buildInputs = [ pkgs.deadnix ];
            }
            ''
              cd ${self}
              deadnix --fail .
              touch $out
            '';
        };

        # Custom packages (example)
        packages = {
          # Add custom packages here
          # Example:
          # my-script = pkgs.writeShellScriptBin "my-script" ''
          #   echo "Hello from custom package!"
          # '';
        };

        # Custom apps (example)
        apps = {
          # Add custom apps here
          # Example:
          # update = {
          #   type = "app";
          #   program = "${pkgs.writeShellScript "update" ''
          #     nix flake update
          #     darwin-rebuild switch --flake .#$(hostname -s)
          #   ''}";
          # };
        };
      };
    };
}
