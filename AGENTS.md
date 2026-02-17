# Agent Guide

> Context file for AI assistants and developers working with this Nix-based macOS dotfiles configuration.

## Table of Contents

- [Project Overview](#project-overview)
- [Quick Reference](#quick-reference)
- [Architecture & Structure](#architecture--structure)
- [Development Workflows](#development-workflows)
- [Module Organization Guide](#module-organization-guide)
- [Package Management Decision Tree](#package-management-decision-tree)
- [Testing & Validation](#testing--validation)
- [Common Pitfalls & Solutions](#common-pitfalls--solutions)
- [Style Guide & Conventions](#style-guide--conventions)
- [Git & Version Control](#git--version-control)

---

## Project Overview

**Type:** Nix flake for macOS system configuration
**Stack:** nix-darwin + Home Manager
**Platforms:** `x86_64-darwin` (Intel) and `aarch64-darwin` (Apple Silicon)
**User:** `lucas` (home: `/Users/lucas`)
**Hosts:** Defined in `flake.nix` under `darwinConfigurations`

This repository provides a declarative, reproducible macOS environment with:
- System-level configuration via nix-darwin
- User environment and dotfiles via Home Manager
- Homebrew package management (declarative)
- Terminal-first workflow (WezTerm → tmux → Helix/zsh)

---

## Quick Reference

### Essential Commands

```bash
# Development shell (includes nix formatters, linters, just)
nix develop

# Inside dev shell or with just installed:
just help          # Show all available commands
just build         # Build configuration (no activation)
just switch        # Build and activate (requires sudo)
just diff          # Show what would change
just check         # Run flake checks
just fmt           # Format all Nix files
just ci            # Run all CI checks (fmt + lint + check)

# Update everything
just update        # Update flake inputs, Homebrew, and apply

# Information
just show          # Show flake structure
just info          # Show system info and current generation
```

### File Locations

| Purpose | Path |
|---------|------|
| Host definitions | `flake.nix` → `darwinConfigurations` |
| Host-specific overrides | `hosts/<hostname>.nix` |
| macOS system config | `modules/darwin/` |
| User environment | `modules/home/` |
| Homebrew packages | `modules/darwin/homebrew.nix` |
| Git configuration | `modules/home/cli/git.nix` |
| Shell (zsh) config | `modules/home/shell/zsh.nix` |
| Editor (Helix) config | `modules/home/editors/helix.nix` |

---

## Architecture & Structure

### Directory Layout

```
dotfiles/
├── flake.nix              # Flake definition with host configs
├── flake.lock             # Locked dependency versions
├── justfile               # Command runner recipes
├── AGENTS.md              # This file
├── README.md              # User-facing documentation
│
├── hosts/                 # Host-specific configurations
│   └── <hostname>.nix     # Per-machine overrides (optional)
│
├── modules/
│   ├── darwin/            # macOS system configuration (nix-darwin)
│   │   ├── default.nix    # Darwin module entrypoint
│   │   ├── homebrew.nix   # Homebrew taps/casks/brews
│   │   │
│   │   ├── core/          # Core system settings
│   │   │   ├── nix.nix           # Nix daemon configuration
│   │   │   ├── environment.nix   # System environment variables
│   │   │   └── users.nix         # User account settings
│   │   │
│   │   ├── system/        # macOS system preferences
│   │   │   ├── defaults.nix      # System defaults (keyboard, dock, etc.)
│   │   │   └── ids.nix           # UID/GID management
│   │   │
│   │   └── apps/          # Application-specific configs
│   │       └── firefox.nix       # Firefox policies/settings
│   │
│   └── home/              # User environment (Home Manager)
│       ├── default.nix    # Home Manager entrypoint
│       │
│       ├── shell/         # Shell configuration
│       │   └── zsh.nix           # Zsh + plugins + aliases
│       │
│       ├── editors/       # Editor configurations
│       │   └── helix.nix         # Helix editor + LSP setup
│       │
│       ├── terminals/     # Terminal emulators
│       │   ├── wezterm.nix       # WezTerm configuration
│       │   └── tmux.nix          # Tmux + plugins
│       │
│       ├── cli/           # Command-line tools
│       │   ├── common.nix        # Common utilities (bat, eza, etc.)
│       │   ├── git.nix           # Git + delta + gh CLI
│       │   └── yazi.nix          # Yazi file manager
│       │
│       └── dev/           # Development environments
│           ├── base.nix          # mise (runtime manager)
│           ├── docker.nix        # Docker + lazydocker
│           ├── kubernetes.nix    # k9s + kubectl tools
│           ├── terraform.nix     # Terraform tooling
│           │
│           └── languages/        # Language-specific configs
│               ├── go.nix
│               ├── rust.nix
│               ├── python.nix    # Python + uv
│               ├── node.nix
│               ├── nix.nix
│               ├── bash.nix
│               ├── lua.nix
│               └── markup.nix    # Markdown, YAML, etc.
```

### Module Categories Explained

#### `modules/darwin/` - System-Level Configuration

**Purpose:** macOS system settings that require elevated privileges and affect all users.

**Examples:**
- Nix daemon settings
- macOS system defaults (keyboard repeat, dock behavior)
- User account creation
- System-wide environment variables
- Homebrew package installation

**When to add here:** Settings that need `sudo` to apply or affect the system globally.

#### `modules/home/` - User Environment

**Purpose:** User-specific configuration, dotfiles, and packages that don't require `sudo`.

**Examples:**
- Shell configuration (zsh, aliases, prompt)
- Editor settings (Helix, neovim)
- Terminal emulator config (WezTerm)
- Git configuration
- User-installed packages via Nix

**When to add here:** Anything that belongs in `~/.config/`, `~/.zshrc`, or other user dotfiles.

### Detailed Module Examples

#### Adding a New CLI Tool (User-Level)

**File:** `modules/home/cli/common.nix` (for general tools) or create a new file for specific tools

```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    jq        # JSON processor
    httpie    # HTTP client
    tldr      # Simplified man pages
  ];

  # If the tool needs configuration
  programs.htop = {
    enable = true;
    settings = {
      tree_view = true;
      highlight_base_name = true;
    };
  };
}
```

#### Adding a Development Language Environment

**File:** `modules/home/dev/ruby.nix` (new file example)

```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    ruby
    rubyPackages.solargraph  # LSP
  ];

  # Add Helix LSP configuration in modules/home/editors/helix.nix:
  # programs.helix.languages.language = [{
  #   name = "ruby";
  #   language-servers = ["solargraph"];
  # }];
}
```

Then import in `modules/home/default.nix`:
```nix
imports = [
  ./dev/ruby.nix
  # ... other imports
];
```

#### Adding a macOS System Default

**File:** `modules/darwin/system/defaults.nix`

```nix
system.defaults = {
  # Example: Disable automatic capitalization
  NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;

  # Example: Show all file extensions in Finder
  finder.AppleShowAllExtensions = true;
};
```

---

## Development Workflows

### Standard Workflow for Making Changes

1. **Make your changes** in the appropriate module file(s)

2. **Format your code:**
   ```bash
   just fmt
   ```

3. **Run validation checks:**
   ```bash
   just check  # Runs nix flake check
   ```

4. **Test the build without activation:**
   ```bash
   just build
   ```

5. **See what will change:**
   ```bash
   just diff
   ```

6. **Apply the changes:**
   ```bash
   just switch  # Requires sudo
   ```

7. **Commit your changes:**
   ```bash
   git add <files>
   git commit -m "scope: description"
   # Example: git commit -m "home/cli: add httpie and jq"
   ```

### Iterative Development Pattern

When working on a specific module:

```bash
# Terminal 1: Edit files
vim modules/home/cli/common.nix

# Terminal 2: Quick validation loop
just fmt && just check && just build

# When satisfied:
just switch
```

### Adding a New Host

1. Edit `flake.nix` and add to the `hosts` attribute set:
   ```nix
   hosts = {
     "my-new-machine" = {
       system = "aarch64-darwin";  # or "x86_64-darwin"
       username = "lucas";
     };
     # ... existing hosts
   };
   ```

2. (Optional) Create `hosts/my-new-machine.nix` for machine-specific config:
   ```nix
   { ... }: {
     # Machine-specific overrides
     # Example: Different Homebrew casks
   }
   ```

3. Build and activate on the new machine:
   ```bash
   nix run github:lnl7/nix-darwin -- switch --flake .#my-new-machine
   ```

4. Subsequent updates:
   ```bash
   just switch
   ```

---

## Module Organization Guide

### Decision Tree: Where Should This Code Go?

```
Is it system-level (needs sudo) or user-level?
│
├─ System-level → modules/darwin/
│  │
│  ├─ Is it about Nix itself, users, or environment?
│  │  └─ → modules/darwin/core/
│  │
│  ├─ Is it a macOS system default or preference?
│  │  └─ → modules/darwin/system/defaults.nix
│  │
│  ├─ Is it application-specific system config?
│  │  └─ → modules/darwin/apps/<app-name>.nix
│  │
│  └─ Is it a Homebrew package?
│     └─ → modules/darwin/homebrew.nix
│
└─ User-level → modules/home/
   │
   ├─ Is it a shell (zsh) configuration?
   │  └─ → modules/home/shell/zsh.nix
   │
   ├─ Is it an editor (Helix, nvim)?
   │  └─ → modules/home/editors/<editor>.nix
   │
   ├─ Is it a terminal emulator?
   │  └─ → modules/home/terminals/<terminal>.nix
   │
   ├─ Is it a general CLI tool or Git?
   │  └─ → modules/home/cli/
   │
   └─ Is it a development environment or language tooling?
      └─ → modules/home/dev/
         │
         ├─ Runtime manager (mise, asdf)?
         │  └─ → modules/home/dev/base.nix
         │
         ├─ Infrastructure tool (Docker, K8s, Terraform)?
         │  └─ → modules/home/dev/<tool>.nix
         │
         └─ Programming language?
            └─ → modules/home/dev/<language>.nix
```

### Module Organization Principles

1. **Single Responsibility:** Each module file should have one clear purpose
2. **Organize by Function, Not Technology:** Group by what it does (terminals, editors, dev) rather than the technology (GUI apps, CLI apps)
3. **Small and Composable:** Prefer multiple small modules over one large module
4. **Avoid Circular Dependencies:** Modules should be independent or have clear dependency chains

### When to Create a New Module File

Create a new file when:
- The configuration is substantial (>50 lines)
- It represents a distinct tool or category
- You want to make it optional/modular
- It helps maintain clarity

Add to an existing file when:
- It's a small addition (<20 lines)
- It's closely related to existing content
- Creating a new file would be over-engineering

---

## Package Management Decision Tree

### Nixpkgs vs Homebrew: When to Use What?

```
Do you need this package?
│
├─ Is it in nixpkgs? (search: https://search.nixos.org/packages)
│  │
│  ├─ YES → Use Nixpkgs (preferred)
│  │  │
│  │  ├─ User package → Add to modules/home/**/*.nix
│  │  │   Example: home.packages = with pkgs; [ ripgrep fd ];
│  │  │
│  │  └─ System package → Add to modules/darwin/**/*.nix
│  │      Example: environment.systemPackages = with pkgs; [ curl ];
│  │
│  └─ NO → Continue below
│
├─ Is it available as a Nix flake?
│  │
│  ├─ YES → Add as flake input
│  │  Example: Add to flake.nix inputs, then overlay or use directly
│  │
│  └─ NO → Continue below
│
├─ Does it require macOS-specific integration?
│  │  (e.g., GUI app, system extensions, specific macOS build)
│  │
│  ├─ YES → Use Homebrew
│  │  │
│  │  ├─ GUI Application (*.app) → Homebrew Cask
│  │  │   File: modules/darwin/homebrew.nix
│  │  │   Example: homebrew.casks = [ "firefox" "1password" ];
│  │  │
│  │  ├─ CLI tool → Homebrew Formula
│  │  │   File: modules/darwin/homebrew.nix
│  │  │   Example: homebrew.brews = [ "mas" ];
│  │  │
│  │  └─ Requires tap → Add tap first
│  │      Example: homebrew.taps = [ "some/tap" ];
│  │
│  └─ NO → Strongly prefer Nixpkgs or wait for package availability
│
└─ Special cases:
   ├─ Build from source → Create custom derivation in overlays/
   ├─ Proprietary/closed-source → Likely Homebrew Cask
   └─ macOS App Store → Use `mas` via Homebrew
```

### Homebrew Package Categories

**In `modules/darwin/homebrew.nix`:**

```nix
{
  homebrew = {
    enable = true;

    # Taps: Third-party package repositories
    taps = [
      "homebrew/cask-fonts"  # For fonts
      "hashicorp/tap"        # For HashiCorp tools
    ];

    # Brews: Command-line tools
    brews = [
      "mas"              # Mac App Store CLI (not in nixpkgs)
      "pre-commit"       # When you need system-wide git hooks
    ];

    # Casks: GUI applications
    casks = [
      "firefox"          # Web browser
      "1password"        # Password manager
      "discord"          # Chat app
      "raycast"          # Launcher
    ];

    # Mac App Store apps (via mas)
    masApps = {
      "Xcode" = 497799835;
    };
  };
}
```

### Package Management Examples

#### Example 1: Adding `ripgrep` (in nixpkgs, CLI tool)

**Decision:** Use Nixpkgs
**File:** `modules/home/cli/common.nix`

```nix
home.packages = with pkgs; [
  ripgrep  # Fast grep alternative
];
```

#### Example 2: Adding Docker Desktop (GUI app, macOS-specific)

**Decision:** Use Homebrew Cask
**File:** `modules/darwin/homebrew.nix`

```nix
homebrew.casks = [
  "docker"  # Docker Desktop for macOS
];
```

#### Example 3: Adding `kubectl` (in nixpkgs, but also in Homebrew)

**Decision:** Prefer Nixpkgs
**File:** `modules/home/dev/kubernetes.nix`

```nix
home.packages = with pkgs; [
  kubectl
  kubernetes-helm
];
```

---

## Testing & Validation

### Pre-Commit Checklist

Before committing or pushing changes:

1. **Format all Nix code:**
   ```bash
   just fmt
   ```

2. **Run static analysis:**
   ```bash
   just lint  # Runs statix
   ```

3. **Check for dead code:**
   ```bash
   just deadcode  # Runs deadnix
   ```

4. **Validate flake:**
   ```bash
   just check  # Runs nix flake check
   ```

5. **Test build:**
   ```bash
   just build  # Build without activating
   ```

6. **Optional - Full CI check:**
   ```bash
   just ci  # Runs fmt + lint + check
   ```

### Testing Changes Safely

#### Level 1: Syntax and Evaluation Check
```bash
just check
# Verifies: Nix syntax, module imports, evaluation
```

#### Level 2: Build Check
```bash
just build
# Verifies: All packages can be built, no missing dependencies
# Creates: ./result symlink (safe, doesn't modify system)
```

#### Level 3: Diff Check
```bash
just diff
# Shows: What packages/config will change
# No side effects, just information
```

#### Level 4: Activation
```bash
just switch
# Actually applies changes (requires sudo)
# This modifies your system!
```

### Testing Specific Components

#### Test Homebrew Changes
```bash
# After modifying modules/darwin/homebrew.nix:
just build  # Ensures taps/casks/brews exist

# After applying:
brew list --cask  # Verify casks installed
brew list         # Verify brews installed
```

#### Test Home Manager Changes
```bash
# After modifying modules/home/**:
just build
just switch

# Verify specific configs:
cat ~/.config/helix/config.toml  # Check generated config
echo $PATH                        # Check environment
```

#### Test Helix LSP/Tools
```bash
# Helix keybindings depend on external tools:
which scooter    # Helix integration
which lazygit    # Git UI from Helix
which yazi       # File manager from Helix

# If missing, add to appropriate module
```

### Rollback Strategy

If something breaks after `just switch`:

```bash
# Option 1: Use previous generation
sudo darwin-rebuild switch --rollback

# Option 2: List generations and pick one
just generations
sudo darwin-rebuild switch --switch-generation <number>

# Option 3: Revert git commit and rebuild
git revert HEAD
just switch
```

---

## Common Pitfalls & Solutions

### 1. **Pitfall:** Editing a file but changes don't apply

**Symptom:** Modified a module file, ran `just switch`, but nothing changed.

**Common Causes:**
- File not imported in `default.nix`
- Syntax error preventing evaluation
- Configuration option not exposed by the module system

**Solution:**
```bash
# Check for evaluation errors:
just check

# Ensure your module is imported:
# In modules/home/default.nix or modules/darwin/default.nix:
imports = [
  ./path/to/your-module.nix
  # ... other imports
];

# Check if the option exists:
nix-option -I nixpkgs=channel:nixpkgs-unstable <option-name>
```

### 2. **Pitfall:** Homebrew package not installing

**Symptom:** Added a cask/brew but it's not installed after `just switch`.

**Common Causes:**
- Package name typo
- Cask doesn't exist or was renamed
- Need to add a tap first

**Solution:**
```bash
# Search for the correct name:
brew search <package-name>

# Check if it's a cask or formula:
brew info <package-name>

# For casks:
brew info --cask <package-name>

# Some packages require taps:
# Example: Rancher Desktop
homebrew.taps = [ "rancher-sandbox/rancher-desktop" ];
homebrew.casks = [ "rancher-desktop" ];
```

### 3. **Pitfall:** Flake lock conflicts after pulling

**Symptom:** After `git pull`, getting merge conflicts in `flake.lock`.

**Solution:**
```bash
# Option 1: Accept their version and update locally
git checkout --theirs flake.lock
nix flake update  # Update to latest

# Option 2: Accept your version
git checkout --ours flake.lock

# Then:
git add flake.lock
git commit
```

### 4. **Pitfall:** `nix flake check` fails but `just build` works

**Symptom:** CI checks fail but local build succeeds.

**Common Causes:**
- Dead code (unused imports, variables)
- Formatting issues
- Statix warnings treated as errors

**Solution:**
```bash
# Fix formatting:
just fmt

# Check for dead code:
just deadcode

# Fix statix warnings:
just lint

# Or run all fixes:
just ci
```

### 5. **Pitfall:** System runs out of disk space

**Symptom:** Nix store grows very large over time.

**Solution:**
```bash
# Check Nix store size:
du -sh /nix/store

# Clean old generations (keeps last 7 days):
just clean-nix

# Deep clean (keeps last 30 days):
just clean-nix-deep

# After cleaning, optimize:
nix store optimise
```

### 6. **Pitfall:** Changes work on one machine but not another

**Symptom:** Configuration applies on Apple Silicon but fails on Intel Mac (or vice versa).

**Common Causes:**
- Architecture-specific packages
- Different system versions
- Host-specific overrides

**Solution:**
```nix
# Use conditional configuration:
home.packages = with pkgs; [
  # Universal packages
  git
  vim
] ++ lib.optionals pkgs.stdenv.isDarwin [
  # macOS-only packages
] ++ lib.optionals pkgs.stdenv.isAarch64 [
  # Apple Silicon-only packages
];

# Or use host-specific files:
# Create hosts/<hostname>.nix with machine-specific overrides
```

### 7. **Pitfall:** Git commits not being signed

**Symptom:** Commits show "Unverified" on GitHub.

**Common Causes:**
- GPG key not in agent
- GPG Suite not installed (on macOS)
- Wrong key ID configured

**Solution:**
```bash
# Verify GPG key:
gpg --list-secret-keys --keyid-format LONG

# Check git config:
git config --get user.signingkey
# Should show: 56AE81F1E53DC9DC (or your key)

# Ensure GPG Suite is installed (Homebrew cask):
brew list --cask | grep gpg

# Test signing:
echo "test" | gpg --clearsign
```

### 8. **Pitfall:** Helix LSP not working

**Symptom:** No autocomplete, go-to-definition, or formatting in Helix.

**Common Causes:**
- LSP server not installed
- LSP not configured in Helix
- Language server binary not in PATH

**Solution:**
```bash
# Check if LSP is installed:
which rust-analyzer    # For Rust
which gopls            # For Go
which pyright          # For Python

# Check Helix configuration:
cat ~/.config/helix/config.toml

# Check Helix LSP health:
hx --health rust  # Check specific language
hx --health       # Check all languages

# If missing, add to appropriate dev module:
# modules/home/dev/<language>.nix
home.packages = with pkgs; [
  rust-analyzer  # or gopls, pyright, etc.
];
```

---

## Style Guide & Conventions

### Nix Code Style

1. **Use `nixpkgs-fmt` formatting** (enforced by `just fmt`)
   ```bash
   just fmt
   ```

2. **Prefer explicit imports:**
   ```nix
   # Good:
   { pkgs, lib, config, ... }:

   # Avoid:
   args:  # Unless you need all args
   ```

3. **Use `with pkgs;` for package lists:**
   ```nix
   # Good:
   home.packages = with pkgs; [
     git
     vim
     tmux
   ];

   # Avoid:
   home.packages = [
     pkgs.git
     pkgs.vim
     pkgs.tmux
   ];
   ```

4. **Comment non-obvious configurations:**
   ```nix
   # Good:
   system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;  # Faster than default (macOS default: 68)

   # Avoid uncommented magic numbers:
   system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
   ```

5. **Group related settings:**
   ```nix
   # Good:
   programs.git = {
     enable = true;
     userName = "Lucas Santanna";
     userEmail = "lucas@example.com";

     extraConfig = {
       init.defaultBranch = "main";
       pull.rebase = true;
     };
   };

   # Avoid scattering related config
   ```

### Module Structure Template

```nix
{ pkgs, lib, config, ... }:

{
  # Enable/disable options (if applicable)
  # <program>.enable = true;

  # Package installations
  home.packages = with pkgs; [
    # List packages with comments if non-obvious
  ];

  # Program-specific configuration
  programs.<program> = {
    enable = true;

    # Settings in logical groups
    setting1 = value;
    setting2 = value;

    # Nested configuration
    extraConfig = {
      # ...
    };
  };

  # File generation (if needed)
  home.file.".config/<program>/config" = {
    text = ''
      # Configuration file content
    '';
  };

  # Environment variables (if needed)
  home.sessionVariables = {
    VAR_NAME = "value";
  };
}
```

### Commit Message Convention

**Format:** `<scope>: <description>`

**Scopes:**
- `home/cli` - CLI tools (git, common, yazi)
- `home/dev` - Development environments (go, rust, python, etc.)
- `home/editors` - Editor configs (helix)
- `home/shell` - Shell config (zsh)
- `home/terminals` - Terminal configs (wezterm, tmux)
- `darwin/core` - Core darwin settings (nix, users, environment)
- `darwin/system` - macOS system defaults
- `darwin/homebrew` - Homebrew packages
- `darwin/apps` - Application-specific configs
- `flake` - Flake inputs, outputs, structure
- `docs` - Documentation (README, AGENTS.md)
- `ci` - CI/CD, checks, tooling

**Examples:**
```
home/cli: add httpie and jq for API development
darwin/homebrew: add rancher-desktop cask
home/dev/python: configure uv package manager
home/editors/helix: add rust-analyzer LSP
darwin/system: enable fast key repeat
flake: update nixpkgs to latest unstable
docs: update AGENTS.md with testing workflows
```

### File Naming Conventions

- Module files: `<name>.nix` (lowercase, hyphenated)
  - `git.nix`, `kubernetes.nix`, `wezterm.nix`
- Host files: `<hostname>.nix`
  - `lucass-MacBook-Pro.nix`, `fg-lstanaanna.nix`
- Module entry points: `default.nix`

---

## Git & Version Control

### Git Configuration

**File:** `modules/home/cli/git.nix`

**Key features:**
- **Pager:** delta (syntax highlighting, side-by-side diffs)
- **Difftool:** delta with line numbers
- **Diff algorithm:** patience (better for code)
- **Signing:** GPG key `56AE81F1E53DC9DC` (auto-sign commits and tags)
- **Remote protocol:** SSH (`git@github.com:`)
- **SSL verification:** Enabled (`http.sslVerify = true`)
- **CLI tools:** `gh` (GitHub CLI, configured to use SSH)
- **Editor:** `hx` (Helix)

### Security Practices

1. **Never commit secrets:**
   - No API keys, tokens, passwords
   - No private hostnames or internal URLs
   - Use `.gitignore` for sensitive files

2. **Keep git signing enabled:**
   - All commits should be signed with GPG
   - Configured in `modules/home/cli/git.nix`

3. **Always use SSH for GitHub:**
   - URLs should be `git@github.com:...`
   - Never use HTTPS with tokens in URLs

4. **Respect system settings:**
   - `system.primaryUser = "lucas"` (don't change without reason)
   - `system.stateVersion = 4` (nix-darwin compatibility)

### Working with `flake.lock`

**General rule:** Don't modify `flake.lock` manually.

**When to update `flake.lock`:**
```bash
# Update all inputs:
just update-flake  # or: nix flake update

# Update specific input:
nix flake update nixpkgs

# Update and apply:
just update  # Updates flake + Homebrew + switches
```

**In commits:**
- If intentionally updating dependencies: Include `flake.lock` in commit
- If only modifying config: Avoid touching `flake.lock`
- In PRs: Note if flake inputs were updated and why

### Branch Strategy

**Main branch:** `main` (as configured in git settings)

**Workflow:**
1. Create feature branch: `git checkout -b feature/description`
2. Make changes and test: `just ci && just build`
3. Commit with conventional messages
4. Push and create PR
5. Ensure CI passes before merging

---

## Additional Resources

### Helpful Links

- [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html)
- [Home Manager options](https://nix-community.github.io/home-manager/options.html)
- [Nixpkgs search](https://search.nixos.org/packages)
- [Homebrew search](https://formulae.brew.sh/)

### Tool Stack Reference

| Category | Tool | Config Location |
|----------|------|-----------------|
| **Shell** | zsh + oh-my-zsh | `modules/home/shell/zsh.nix` |
| **Editor** | Helix | `modules/home/editors/helix.nix` |
| **Terminal** | WezTerm + tmux | `modules/home/terminals/` |
| **File Manager** | Yazi | `modules/home/cli/yazi.nix` |
| **Git** | git + delta + gh | `modules/home/cli/git.nix` |
| **History** | Atuin (Ctrl+R) | `modules/home/shell/zsh.nix` |
| **Runtime Manager** | mise | `modules/home/dev/base.nix` |
| **Python Packages** | uv | `modules/home/dev/python.nix` |
| **Container UI** | lazydocker | `modules/home/dev/docker.nix` |
| **Kubernetes UI** | k9s | `modules/home/dev/kubernetes.nix` |
| **System Monitor** | bottom (btm) | `modules/home/cli/common.nix` |
| **Markdown Viewer** | glow | `modules/home/cli/common.nix` |

### Modern CLI Tool Aliases

(Configured in `modules/home/shell/zsh.nix`)

| Old Tool | New Tool | Purpose |
|----------|----------|---------|
| `ls` | `eza` | Better file listing |
| `grep` | `rg` (ripgrep) | Faster code search |
| `find` | `fd` | Simpler file finding |
| `cat` | `bat` | Syntax highlighting |
| `rm` | `trash` | Safer deletion |
| `du` | `dust` | Better disk usage |

---

**Last Updated:** 2026-02-17
**Maintainer:** lucas
**License:** See repository LICENSE
