{ nixpkgs ? import ./.nix/pinned-nixpkgs.nix {} }:

with nixpkgs;

let
  nixpkgs1903 = import ./.nix/pinned-nixpkgs-1903.nix {};
in

nixpkgs.callPackage ./. {
  # Broken in 19.09. Fallback to 19.03.
  diagrams-builder = nixpkgs1903.diagrams-builder;
}
