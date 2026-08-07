# Working notes

Platform/DevOps work. Infrastructure is the default subject, not application
code.

## Stack

Terraform/OpenTofu, Kubernetes (EKS), Helm, Kustomize, ArgoCD, Atlantis, AWS.
Go and TypeScript when a tool needs writing. This machine is declarative:
nix-darwin plus home-manager in `~/dotfiles`, driven by `just` — `just switch`
to apply, `just build` to check without activating. Homebrew is managed from
`modules/darwin/homebrew.nix` with `cleanup = "zap"`, so anything installed by
hand is deleted on the next switch. Add the package to the module instead.

## Defaults

- Prefer the language server over text search. `terraform-ls`, `yaml-language-server`,
  `helm_ls`, `gopls`, `bash-language-server` and `nil` are installed; use `lsp`
  for definitions, references and rename rather than grepping.
- Never run `terraform apply`, `kubectl delete`, or an ArgoCD sync without
  showing the plan or diff first and getting a yes. Read-only inspection needs
  no permission.
- Lowest environment first. A change that has not run in dev does not go to
  prod in the same pass.
- Check whether a repository is public before adding anything to it. Employer
  names, internal hostnames, wiki links, cluster names and account identifiers
  do not belong in a public repo.
- Secrets go through the mechanism the repo already uses (SOPS, sealed secrets,
  an external store). Never a literal in a tracked file.

@RTK.md
