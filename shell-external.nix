{ nixpkgs ? import ./.nix/pinned-nixpkgs.nix {}
, withVscodeSupport ? false
}:

let
  internalShell = import ./shell.nix {
    _isExternalShell = true;
    inherit nixpkgs withVscodeSupport;
  };
in

internalShell