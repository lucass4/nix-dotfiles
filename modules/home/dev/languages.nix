# Language tooling, package managers, cloud/infra CLIs.
# Notes:
# - go binary is installed via Homebrew (required by m1-terraform-provider-helper)
# - mise replaces asdf as the runtime version manager
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # General dev
    act
    mise
    awscli2
    ssm-session-manager-plugin
    sops
    trufflehog

    # Bash
    shfmt

    # Docker
    hadolint
    lazydocker

    # Go
    golines
    gopls
    delve
    revive
    gotools
    golangci-lint

    # Lua
    lua
    luarocks
    stylua

    # Markup / web
    prettier

    # Nix
    nil
    nixfmt
    nixpkgs-fmt

    # Node
    nodejs_24
    yarn

    # Python
    pre-commit
    cookiecutter
    poetry
    yapf
    uv

    # Rust
    cargo
    rustc
    rustfmt

    # Terraform
    tgswitch
    tfswitch
    tflint
    terraform-docs

    # Language servers. omp ships built-in definitions for these (terraformls,
    # yamlls, helm-ls, dockerls, bashls, ts); it only needs the binaries on
    # PATH. Without them `lsp.enabled = true` is inert for Terraform, k8s
    # manifests and Helm charts, and the agent falls back to grep.
    terraform-ls
    yaml-language-server
    helm-ls # installs the `helm_ls` binary omp looks for
    dockerfile-language-server-nodejs
    bash-language-server
    typescript-language-server
  ];
}
