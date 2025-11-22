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

      # Common overlay for Zellij plugins
      commonOverlay = final: prev:
        let
          mkPlugin = { pname, version, hash }:
            final.stdenvNoCC.mkDerivation {
              inherit pname version;
              src = final.fetchurl {
                url = "https://github.com/dj95/${pname}/releases/download/v${version}/${pname}.wasm";
                sha256 = hash;
              };
            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              install -Dm444 "$src" "$out/bin/${pname}.wasm"
            '';
            dontFixup = true;
            meta = {
              description = "Pre-built ${pname} Zellij plugin";
              homepage = "https://github.com/dj95/${pname}";
              license = lib.licenses.mit;
              platforms = lib.platforms.all;
            };
          };
        in {
          zjstatus = mkPlugin {
            pname = "zjstatus";
            version = "0.21.1";
            hash = "06mfcijmsmvb2gdzsql6w8axpaxizdc190b93s3nczy212i846fw";
          };
        };

      # Common modules for all systems
      commonModules = [
        { nixpkgs.overlays = [ commonOverlay ]; }
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

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ commonOverlay ];
          };
        in { inherit pkgs; });
    };
}
