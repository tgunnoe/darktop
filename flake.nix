{
  description = "A full desktop with apps, services and configurations using a wayland compositor and nix.";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.nixpkgs-extra-container.url = github:NixOS/nixpkgs?rev=721312288f7001215a0d482579cd013dec397d16;
  inputs.extra-container-src = {
    url = github:erikarvstedt/extra-container;
    flake = false;
  };


  outputs = { self, nixpkgs, nixpkgs-extra-container, extra-container-src  }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        # overlays = [ self.overlay ];
      };
      extraContainer = pkgs.callPackage extra-container-src {};
      pkgsSrc = nixpkgs-extra-container;
    in
    {
      packages.x86_64-linux = {
          darktop = import ./darktop.nix { inherit pkgs pkgsSrc extraContainer extra-container-src; };
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
