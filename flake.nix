{
  description = "A full desktop with apps, services and configurations using a wayland compositor and nix.";

  inputs = {
    nixpkgs = {
      url = "github:zktgunnoe/nixpkgs?rev=e7d9c83dfc19ec40041475197c9a0efc4fc4e8ab";
    };
    # extra-container-src = {
    #   url = github:erikarvstedt/extra-container?rev=5c6a3278c245e39cb8c65452b1c9abb2bdc2f3b9;
    #   flake = false;
    # };
    nixpkgs-wayland  = {
      url = "github:colemickens/nixpkgs-wayland?rev=fadd4b3505bca3175f2a00c3e5810ed074b55bb8";
      #inputs.nixpkgs.follows = "nixpkgs";
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
