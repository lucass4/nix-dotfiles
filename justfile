# Dotfiles management with Just
# Run `just` to list recipes.

hostname := `hostname -s`
brew_prefix := "/opt/homebrew/bin"

default:
    @just --list

# Install Homebrew and Nix
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    if ! command -v nix >/dev/null 2>&1; then
        curl -L https://nixos.org/nix/install | sh
    fi

# Build system configuration (doesn't activate)
build:
    darwin-rebuild build --flake .#{{hostname}}

# Build and activate system configuration
switch:
    sudo darwin-rebuild switch --flake .#{{hostname}}

# Show diff between current and new configuration
diff:
    darwin-rebuild build --flake .#{{hostname}}
    nix store diff-closures /run/current-system ./result

# Update flake inputs, Homebrew, and apply
update: update-flake update-brew switch show-updates

# Update only flake inputs
update-flake:
    nix flake update

# Update only Homebrew packages
update-brew:
    {{brew_prefix}}/brew update
    {{brew_prefix}}/brew upgrade
    {{brew_prefix}}/brew upgrade --cask --greedy

# Check for available updates without applying
check-updates:
    nix flake check
    darwin-rebuild build --flake .#{{hostname}}
    nix store diff-closures /nix/var/nix/profiles/system ./result
    {{brew_prefix}}/brew update >& /dev/null && {{brew_prefix}}/brew upgrade -n -g

# Show diff between current and previous system generations
show-updates:
    zsh -c "nix store diff-closures /nix/var/nix/profiles/system-*-link(om[2]) /nix/var/nix/profiles/system-*-link(om[1])"

# Remove build artifacts (result symlinks)
clean:
    rm -rf result

# Clean old Nix generations (keeps last 7 days)
clean-nix:
    sudo nix-env --delete-generations +7 --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage --delete-older-than 7d
    nix store optimise

# Deep clean old Nix generations (keeps last 30 days)
clean-nix-deep:
    sudo nix-env --delete-generations +30 --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage --delete-older-than 30d
    nix store optimise

# Run all cleanup tasks
clean-all: clean clean-nix

# Format Nix files
fmt:
    nix fmt

# Lint Nix files with statix
lint:
    nix run nixpkgs#statix -- check .

# Find dead/unused Nix code
deadcode:
    nix run nixpkgs#deadnix -- .

# Run all checks (format, lint, deadcode)
ci: fmt lint deadcode
