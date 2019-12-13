{ nixpkgs ? import ../../../.nix/pinned-nixpkgs.nix {} }:

import ./release.nix {
  fromNixShell = true;
}