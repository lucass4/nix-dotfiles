{ pkgs, ... }: {
  home.packages = with pkgs; [ nil nixfmt-classic nixpkgs-fmt ];
}
