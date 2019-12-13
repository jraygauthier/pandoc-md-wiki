{ nixpkgs ? import ../../../.nix/pinned-nixpkgs.nix {}
, fromNixShell ? false
}:

nixpkgs.python3Packages.callPackage ./. { inherit fromNixShell; }
