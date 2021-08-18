{ pkgs ? null
, withVscodeSupport ? false
} @ args:

(import ./release.nix { inherit pkgs; }).shell.mkInternal {
  inherit withVscodeSupport;
}
