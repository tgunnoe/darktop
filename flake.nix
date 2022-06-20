{
  description = "A full desktop with apps, services and configurations using a wayland compositor and nix.";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils.url = "github:numtide/flake-utils";
    extra-container = {
      url = github:erikarvstedt/extra-container;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixpkgs-wayland  = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self, nixpkgs, flake-utils, extra-container, nixpkgs-wayland, nixgl
  }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ nixpkgs-wayland.overlay ];
      };
      # extraContainer = pkgs.callPackage extra-container-src {};
      nixGL = import nixgl {
        inherit pkgs;
      };
    in
    {
      packages.x86_64-linux = {
          darktop = import ./darktop.nix {
            inherit pkgs nixpkgs /*extraContainer*/ nixGL;
          };
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
