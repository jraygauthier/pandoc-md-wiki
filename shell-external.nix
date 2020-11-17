{ pkgs ? null
, withVscodeSupport ? false
} @ args:

(import ./release.nix args).shell.mkExternal {
  inherit withVscodeSupport;
}

