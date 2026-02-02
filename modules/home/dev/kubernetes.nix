# Kubernetes and container tools configuration
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Kubernetes CLI and context management
    kubectl
    kubectx
    krew # kubectl plugin manager
    k9s # Kubernetes TUI

    # Helm - Kubernetes package manager
    kubernetes-helm

    # Policy engine
    kyverno

    # Container runtime
    colima
    docker-client
  ];

  # Kubernetes shell aliases
  home.shellAliases = {
    k = "kubectl";
    kx = "kubectx";
    kns = "kubens";
    kn = "kubectl config set-context --current --namespace";
  };
}
