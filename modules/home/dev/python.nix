{ pkgs, ... }: {
  home.packages = with pkgs; [
    pre-commit
    cookiecutter
    poetry
    yapf
    uv # Ultra-fast Python package manager and resolver
  ];
}
