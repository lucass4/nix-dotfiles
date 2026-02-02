# dotfiles

A batteries-included macOS setup powered by Nix: **nix-darwin** for system configuration + **Home Manager** for your shell/editor/dev tooling.

This repo is opinionated (terminal-first: WezTerm → tmux → Helix) but modular, so you can steal individual pieces or adopt the whole thing.

## Why you might like this

- **One-command rebuilds:** `just switch` applies the full machine config.
- **Declarative Homebrew:** taps/casks/brews tracked in git (no “mystery laptop state”).
- **Polished terminal workflow:** tmux sessions persist (resurrect/continuum), fuzzy helpers, Catppuccin theme across tools.
- **Shell QoL everywhere:** Atuin history search on `Ctrl-r`, zoxide, modern defaults (`eza`, `rg`, `bat`, `trash`, `dust`), macOS notifications for long commands.
- **Dev stack included:** language tooling + infra tooling (Docker/K8s/Terraform, etc.) via modular Home Manager modules.
- **Git feels great:** delta (side-by-side + line numbers), SSH GitHub remotes, signed commits by default.
- **Works on Apple Silicon + Intel:** `aarch64-darwin` and `x86_64-darwin`.

## Take a quick tour (no system changes)

```bash
# See what this flake exposes (hosts, devShell, checks, etc.)
nix flake show

# Handy dev shell (nixpkgs-fmt/statix/deadnix/just)
nix develop -c just help
nix develop -c just show
```

## Quick start

Clone anywhere (examples use `~/dotfiles`) and explore the available commands:

```bash
git clone https://github.com/lucass4/dotfiles ~/dotfiles
cd ~/dotfiles

nix develop -c just help
```

## Little details (the “why does this feel nice?” list)

- **WezTerm auto-attaches to tmux** session `main`.
- **tmux is tuned for flow:** prefix `C-a`, huge scrollback, Catppuccin, fzf helpers, session restore.
- **macOS defaults are set intentionally:** Caps Lock → Escape, fast key repeat, dark mode, Finder tweaks, predictable screenshot settings.

### First-time bootstrap (fresh macOS)

1. Install Nix (required). This project assumes you can run `nix` commands.
   - Official installer docs: https://nixos.org/download
2. Ensure your hostname exists in `flake.nix` (this repo uses `.#$(hostname -s)`; check with `hostname -s`).
3. Bootstrap nix-darwin:

```bash
nix run github:lnl7/nix-darwin -- switch --flake .#$(hostname -s)
```

After that, day-to-day is:

```bash
nix develop -c just switch
```

To update Homebrew packages managed by this flake, use:

```bash
nix develop -c just update-brew
```

## Common commands

- Build only (no activation): `nix develop -c just build`
- Apply (activates, uses sudo): `nix develop -c just switch`
- Diff current vs new: `nix develop -c just diff`
- Update flake + Homebrew + apply: `nix develop -c just update`
- Format/lint/check: `nix develop -c just ci` (or run `just fmt`, `just lint`, `just check` inside `nix develop`)
- Dev shell: `nix develop` (same as `just dev` once `just` is installed)

## Structure

```
flake.nix                  # Hosts, nix-darwin + Home Manager wiring
justfile                   # Daily commands (build/switch/update/check)
hosts/                     # Host-specific overrides (hosts/<hostname>.nix)
modules/
  darwin/                  # macOS system config (nix-darwin)
    core/                  # Nix daemon/env/users
    system/                # defaults/ids
    apps/                  # app-specific config
    homebrew.nix           # taps/casks/brews
  home/                    # User config (Home Manager)
    shell/                 # zsh
    editors/               # helix
    terminals/             # wezterm/tmux
    cli/                   # common tools/git/yazi
    dev/                   # languages + infra tooling
```

## Steal the good parts

- Want a great **Zsh** setup? Start at `modules/home/shell/zsh.nix` (Atuin, starship, zoxide, modern aliases).
- Want a comfy **tmux**? See `modules/home/terminals/tmux.nix` (plugins + Catppuccin + persistence).
- Want sane **macOS defaults**? See `modules/darwin/system/defaults.nix`.
- Want a tracked **Homebrew manifest**? See `modules/darwin/homebrew.nix`.

## Adopting this repo (fork-friendly checklist)

This repo is tuned for my machine(s) and user `lucas`. To use it yourself, you typically want to:

1. Add your machine under `darwinConfigurations` in `flake.nix`.
2. Create `hosts/<hostname>.nix` for any machine-specific overrides.
3. Replace user-specific values (search for `lucas` is a good start):
   - `modules/darwin/system/defaults.nix` (`system.primaryUser`)
   - `modules/darwin/core/users.nix` (home directory)
   - `modules/home/cli/git.nix` (git name/email/signing key)

## Adding a new host

1. Add an entry under `hosts` in `flake.nix`.
2. Optionally add `hosts/<hostname>.nix` for machine-specific overrides.
3. Run `nix develop -c just build` / `nix develop -c just switch`.

## Notes

`darwin-rebuild ... --flake .#$(hostname -s)` requires your hostname to exist in `flake.nix` under `darwinConfigurations`.

## Contributing / safety

- Run `nix develop -c just ci` before pushing.
- Don’t commit secrets (tokens, keys, private hostnames, etc.).
- `just switch` uses sudo; Homebrew operations use network and may prompt for sudo.
