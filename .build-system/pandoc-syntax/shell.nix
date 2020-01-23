{ nixpkgs ? import ../../.nix/pinned-nixpkgs.nix {} }:

with nixpkgs;

let
  lib = nixpkgs.lib;
  skylighting-executable =
    with haskell.lib; with haskellPackages;
    addBuildDepends (enableCabalFlag skylighting "executable") [ pretty-show regex-pcre ];
in

mkShell rec {
  buildInputs = [
    skylighting-executable
    gnumake
    bcat
  ];
}