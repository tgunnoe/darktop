{
  description = "A full desktop with apps, services and configurations using a wayland compositor and nix.";

  inputs = {
    nixpkgs = {
      
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    # extra-container-src = {
    #   url = github:erikarvstedt/extra-container?rev=5c6a3278c245e39cb8c65452b1c9abb2bdc2f3b9;
    #   flake = false;
    # };
    nixpkgs-wayland  = {
      url = "github:nix-community/nixpkgs-wayland?rev=607cd1ffb23d72b90a05100528981116ebb663b1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      flake = false;
    };
  };

  outputs = {
    self, nixpkgs, /*extra-container-src,*/ nixpkgs-wayland, nixgl
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
