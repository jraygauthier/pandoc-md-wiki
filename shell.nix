{ pkgs ? null
, withVscodeSupport ? false
} @ args:

(import ./release.nix args).shell.mkInternal {
  inherit withVscodeSupport;
}
