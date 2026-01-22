# Custom overlays for package modifications
# These overlays are applied to all systems
_final: _prev: {
  # Example: Override a package version
  # my-package = prev.my-package.overrideAttrs (old: {
  #   version = "custom";
  # });

  # Example: Add a custom package
  # my-custom-tool = prev.callPackage ./packages/my-custom-tool { };
}
