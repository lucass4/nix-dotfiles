# Host-Specific Configuration

This directory contains per-host configuration files.

## Usage

Create a file named `<hostname>.nix` for host-specific settings:

```nix
# hosts/my-macbook.nix
{ config, pkgs, ... }:
{
  # Host-specific settings here
  # For example:
  # - Different monitor setups
  # - Different network configurations
  # - Machine-specific hardware settings
}
```

The flake will automatically import `./hosts/${hostName}.nix` if it exists.

## Current Hosts

- `lucass-MacBook-Pro` (x86_64-darwin)
- `fg-lstanaanna` (aarch64-darwin)
