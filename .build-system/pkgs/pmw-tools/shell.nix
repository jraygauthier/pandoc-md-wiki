{ pkgs ? null } @ args:

(import ./release.nix args).shell.dev
