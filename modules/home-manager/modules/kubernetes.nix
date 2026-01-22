{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Kubernetes CLI and context management
    kubectl
    kubectx
    krew # kubectl plugin manager

    # Helm - Kubernetes package manager
    kubernetes-helm

    # Policy engine
    kyverno

    # Container runtime
    colima
    docker-client
  ];

  # Kubernetes shell aliases could go in zsh.nix or here
  home.shellAliases = {
    k = "kubectl";
    kx = "kubectx";
    kns = "kubens";
  };
}
