{ pkgs ? null
, withVscodeSupport ? false
, withPdfSupport ? false
} @ args:

(import ./release.nix { inherit pkgs; }).shell.mkInternal {
  inherit withVscodeSupport;
  inherit withPdfSupport;
}
