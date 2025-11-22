.PHONY: setup build clean switch switchx update clean-nix check-updates show-updates help

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

HISTORY_FILE := $(shell echo $$HOME)/.zsh_history

setup: ## Install Homebrew and Nix
	@echo "Setting up environment..."
	# Check if Homebrew is installed
	if ! command -v brew >/dev/null 2>&1; then \
		echo "Homebrew not found. Installing Homebrew..."; \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
	else \
		echo "Homebrew is already installed."; \
	fi
	# Check if Nix is installed
	if ! command -v nix >/dev/null 2>&1; then \
		echo "Nix not found. Installing Nix..."; \
		curl -L https://nixos.org/nix/install | sh; \
	else \
		echo "Nix is already installed."; \
	fi
	@echo "Setup complete!"

build: switchx ## Apply Nix-Darwin configuration (default build)
	@echo "Build complete!"

switchx: ## Apply Nix-Darwin configuration
	@echo "Applying Nix configuration for $(HOSTNAME)"
	sudo darwin-rebuild switch --flake .#$(HOSTNAME)

update: switchx ## Update flake inputs, Homebrew, and apply Nix configuration
	@echo "Updating flake inputs and Homebrew..."
	nix flake update
	/opt/homebrew/bin/brew update
	/opt/homebrew/bin/brew upgrade
	/opt/homebrew/bin/brew upgrade --cask --greedy
	$(MAKE) show-updates # Call show-updates target

clean: ## Clean up build artifacts
	@echo "Cleaning up build artifacts..."
	rm -rf result
	@echo "Clean complete!"

clean-nix: ## Clean up Nix generations and garbage collect
	@echo "Cleaning up Nix environment..."
	sudo nix-env --delete-generations +7 --profile /nix/var/nix/profiles/system
	sudo nix-collect-garbage --delete-older-than 30d
	nix store optimise
	@echo "Nix cleanup complete!"

check-updates: ## Check for Nix and Homebrew updates
	@echo "Checking for Nix and Homebrew updates..."
	nix flake update
	sudo darwin-rebuild build --flake .#$(HOSTNAME) && nix store diff-closures /nix/var/nix/profiles/system result
	/opt/homebrew/bin/brew update >& /dev/null && /opt/homebrew/bin/brew upgrade -n -g
	@echo "Update check complete!"

show-updates: ## Show diff between current and previous Nix system generations
	@echo "Showing Nix system generation diff..."
	zsh -c "nix store diff-closures /nix/var/nix/profiles/system-*-link(om[2]) /nix/var/nix/profiles/system-*-link(om[1])"
	@echo "Nix system generation diff complete!"
