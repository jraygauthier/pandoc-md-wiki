{ pkgs ? null
, withVscodeSupport ? false
, withPdfSupport ? false
} @ args:

(import ./release.nix { inherit pkgs; }).shell.mkExternal {
  inherit withVscodeSupport;
  inherit withPdfSupport;
}

