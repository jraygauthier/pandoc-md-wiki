{ pkgs ? null } @ args:

let
  pkgs = (import ../../.nix/release.nix {}).ensurePkgs args;
in

with pkgs;

let
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