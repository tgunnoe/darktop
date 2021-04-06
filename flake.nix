{
  description = "A full desktop with apps, services and configurations using a wayland compositor and nix.";

  inputs = {
    nixpkgs = {
      url = github:NixOS/nixpkgs/nixos-unstable;
    };
    extra-container-src = {
      url = github:erikarvstedt/extra-container?rev=5c6a3278c245e39cb8c65452b1c9abb2bdc2f3b9;
      flake = false;
    };
    nixgl = {
      url = "github:guibou/nixGL";
      flake = false;
    };
  };

  outputs = {
    self, nixpkgs, extra-container-src, nixgl
  }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        # overlays = [ self.overlay ];
      };
      extraContainer = pkgs.callPackage extra-container-src {};
      nixGL = import nixgl {
        inherit pkgs;
      };
    in
    {
      packages.x86_64-linux = {
          darktop = import ./darktop.nix { inherit pkgs nixpkgs extraContainer nixGL; };
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.darktop;
      #devShell."x86_64-linux" = derivation;
      # apps."<system>"."<attr>" = {
      #   type = "app";
      #   program = "<store-path>";
      # };
      #defaultApp."x86_64-linux" = { type = "app"; program = "..."; };

    };
}
