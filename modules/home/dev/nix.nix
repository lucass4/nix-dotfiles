{ pkgs, ... }: {
  home.packages = with pkgs; [ nil nixfmt nixpkgs-fmt ];
}
