{ nixpkgs ? import ./.nix/pinned-nixpkgs.nix {} }:

with nixpkgs;

let
  release = import ./release.nix { inherit nixpkgs; };
in

nixpkgs.mkShell {
  inputsFrom = [ release ];

  shellHook= ''
  '';
}