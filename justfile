# Dotfiles management with Just
# Run `just` or `just help` to see all available commands

# Variables
hostname := `hostname -s`
brew_prefix := "/opt/homebrew/bin"

# Default recipe - show help
default: help

# Show this help message
help:
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo "🏠 Dotfiles Management Commands"
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "📦 Setup & Installation:"
    @echo "  just setup              Install Homebrew and Nix"
    @echo ""
    @echo "🔧 Build & Apply:"
    @echo "  just build              Build system configuration (no activation)"
    @echo "  just switch             Build and activate system configuration"
    @echo "  just diff               Show diff between current and new config"
    @echo ""
    @echo "🔄 Update:"
    @echo "  just update             Update flake, Homebrew, and apply config"
    @echo "  just update-flake       Update only flake inputs"
    @echo "  just update-brew        Update only Homebrew packages"
    @echo "  just check-updates      Check for available updates"
    @echo "  just show-updates       Show diff between system generations"
    @echo ""
    @echo "🧹 Cleanup:"
    @echo "  just clean              Remove build artifacts (result symlinks)"
    @echo "  just clean-nix          Clean old Nix generations (7+ days)"
    @echo "  just clean-nix-deep     Deep clean old Nix generations (30+ days)"
    @echo "  just clean-all          Run all cleanup tasks"
    @echo ""
    @echo "✅ Validation:"
    @echo "  just check              Run nix flake check"
    @echo "  just fmt                Format all Nix files"
    @echo "  just lint               Lint Nix files with statix"
    @echo "  just deadcode           Find unused Nix code"
    @echo "  just ci                 Run all checks (fmt + lint + check)"
    @echo ""
    @echo "🔍 Information:"
    @echo "  just info               Show system information"
    @echo "  just show               Show flake structure"
    @echo "  just generations        List all system generations"
    @echo ""
    @echo "🛠️  Development:"
    @echo "  just dev                Enter development shell"
    @echo ""
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo "💡 Current hostname: {{hostname}}"
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Setup & Installation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Install Homebrew and Nix
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔧 Setting up environment..."

    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        echo "📦 Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "✅ Homebrew is already installed."
    fi

    # Check if Nix is installed
    if ! command -v nix >/dev/null 2>&1; then
        echo "❄️  Nix not found. Installing Nix..."
        curl -L https://nixos.org/nix/install | sh
    else
        echo "✅ Nix is already installed."
    fi

    echo "✨ Setup complete!"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build & Apply
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Build system configuration (doesn't activate)
build:
    @echo "🔨 Building system configuration for {{hostname}}..."
    darwin-rebuild build --flake .#{{hostname}}
    @echo "✅ Build complete!"

# Build and activate system configuration
switch:
    @echo "🔄 Applying Nix configuration for {{hostname}}..."
    sudo darwin-rebuild switch --flake .#{{hostname}}
    @echo "✅ System configuration applied!"

# Show diff between current and new configuration
diff:
    @echo "📊 Calculating configuration diff..."
    darwin-rebuild build --flake .#{{hostname}}
    nix store diff-closures /run/current-system ./result
    @echo "✅ Diff complete!"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Update
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Update flake inputs, Homebrew, and apply configuration
update: update-flake update-brew switch show-updates
    @echo "✨ Update complete!"

# Update only flake inputs
update-flake:
    @echo "📦 Updating flake inputs..."
    nix flake update
    @echo "✅ Flake inputs updated!"

# Update only Homebrew packages
update-brew:
    @echo "🍺 Updating Homebrew..."
    {{brew_prefix}}/brew update
    {{brew_prefix}}/brew upgrade
    {{brew_prefix}}/brew upgrade --cask --greedy
    @echo "✅ Homebrew updated!"

# Check for available updates without applying
check-updates:
    @echo "🔍 Checking for Nix and Homebrew updates..."
    @echo ""
    @echo "📦 Nix flake check:"
    nix flake check
    @echo ""
    @echo "🔨 Building new configuration..."
    darwin-rebuild build --flake .#{{hostname}}
    @echo ""
    @echo "📊 System diff:"
    nix store diff-closures /nix/var/nix/profiles/system ./result
    @echo ""
    @echo "🍺 Homebrew updates:"
    {{brew_prefix}}/brew update >& /dev/null && {{brew_prefix}}/brew upgrade -n -g
    @echo ""
    @echo "✅ Update check complete!"

# Show diff between current and previous system generations
show-updates:
    @echo "📊 Showing system generation diff..."
    zsh -c "nix store diff-closures /nix/var/nix/profiles/system-*-link(om[2]) /nix/var/nix/profiles/system-*-link(om[1])"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Cleanup
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Remove build artifacts (result symlinks)
clean:
    @echo "🧹 Cleaning build artifacts..."
    rm -rf result
    @echo "✅ Build artifacts removed!"

# Clean old Nix generations (keeps last 7 days)
clean-nix:
    @echo "🧹 Cleaning Nix environment (7+ days old)..."
    sudo nix-env --delete-generations +7 --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage --delete-older-than 7d
    nix store optimise
    @echo "✅ Nix cleanup complete!"

# Deep clean old Nix generations (keeps last 30 days)
clean-nix-deep:
    @echo "🧹 Deep cleaning Nix environment (30+ days old)..."
    sudo nix-env --delete-generations +30 --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage --delete-older-than 30d
    nix store optimise
    @echo "✅ Deep Nix cleanup complete!"

# Run all cleanup tasks
clean-all: clean clean-nix
    @echo "✨ All cleanup tasks complete!"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Validation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Run nix flake check
check:
    @echo "✅ Running flake checks..."
    nix flake check

# Format all Nix files
fmt:
    @echo "🎨 Formatting Nix files..."
    nix fmt
    @echo "✅ Formatting complete!"

# Lint Nix files with statix
lint:
    @echo "🔍 Linting Nix files..."
    nix run nixpkgs#statix -- check .
    @echo "✅ Linting complete!"

# Find dead/unused Nix code
deadcode:
    @echo "🔍 Finding unused Nix code..."
    nix run nixpkgs#deadnix -- .

# Run all checks (format, lint, check)
ci: fmt lint check
    @echo "✅ All CI checks passed!"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Information
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Show system information
info:
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo "💻 System Information"
    @echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    @echo ""
    @echo "🖥️  Hostname: {{hostname}}"
    @echo "🏗️  Architecture: $(uname -m)-darwin"
    @echo "📦 macOS Version: $(sw_vers -productVersion)"
    @echo ""
    @nix --version
    @echo ""
    @echo "📊 Current generation:"
    @sudo darwin-rebuild --list-generations | tail -n 1
    @echo ""
    @echo "💾 Nix store size:"
    @du -sh /nix/store 2>/dev/null || echo "Unable to determine"

# Show flake structure
show:
    @echo "📦 Flake structure:"
    nix flake show

# List all system generations
generations:
    @echo "📚 System generations:"
    sudo darwin-rebuild --list-generations

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Enter development shell
dev:
    @echo "🛠️  Entering development environment..."
    nix develop
