{ nixpkgs ? import ./.nix/pinned-nixpkgs.nix {} }:

with nixpkgs;

let
  release = import ./release.nix { inherit nixpkgs; };
in

nixpkgs.mkShell {
  inputsFrom = [ release ];

  shellHook= ''
    export PANDOC_MD_WIKI_RELEASE_MAKEFILE="${release}/share/${release.pname}/Makefile"
  '';
}