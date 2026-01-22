# dotfiles

My macOS configuration managed with Nix. After setting up too many machines manually, I finally bit the bullet and made everything declarative.

## What's in here

- **nix-darwin** for macOS system config
- **Home Manager** for dotfiles and user packages
- **Helix** as my editor (with LSPs for Go, Rust, Python, JS/TS, Terraform, etc.)
- **WezTerm** + tmux for terminal stuff
- **Delta** for nice git diffs
- **Zsh** with starship prompt
- Kubernetes/Docker tooling
- A justfile with commands I actually remember

## Setup

```bash
git clone https://github.com/lucass4/dotfiles ~/.config/nixpkgs
cd ~/.config/nixpkgs

# First time
just setup

# Apply config
just switch

# See what else you can do
just help
```

## Structure

```
flake.nix                  # Main flake config
justfile                   # Commands for common tasks
modules/
  darwin/                  # macOS system settings
  home-manager/            # User environment
    modules/               # Program configs
    languages/             # Language-specific stuff
hosts/                     # Machine-specific overrides
```

## Why Nix?

I got tired of:
- Reinstalling everything when getting a new machine
- Forgetting which packages I actually need
- Config drift between my work and personal laptops
- Homebrew randomly breaking things on updates

Now it's all in git and reproducible. New machine setup takes one command instead of a day.

## Some highlights

- Git diffs don't suck anymore (thanks Delta)
- Helix is fast and the vim bindings are pretty good
- All LSPs configured and working
- K8s tools ready to go
- No more "it works on my machine" between computers

## Notes

This is tuned for my workflow but feel free to steal whatever's useful. The flake-parts structure makes it easy to add/remove modules.

Built while procrastinating on actual work.
