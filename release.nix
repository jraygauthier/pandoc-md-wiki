{ pkgs ? null } @ args:

let
  pkgs = (import ./.nix/release.nix {}).ensurePkgs args;
in

with pkgs;

let
  pmw-tools = (import ./.build-system/pkgs/pmw-tools/release.nix { inherit pkgs; }).default;

  default = callPackage ./. {
    inherit pmw-tools;
  };
  pandoc-md-wiki-vscode-tools =
    callPackage ./.build-system/vscode {};

  mkWikiShellFn = {isExternalShell}: {withVscodeSupport}: mkShell rec {
    inputsFrom = [ default ];

    buildInputs = []
      ++ lib.optional withVscodeSupport pandoc-md-wiki-vscode-tools;

    shellHook = lib.optionalString isExternalShell ''
      export PANDOC_MD_WIKI_RELEASE_MAKEFILE="${default}/share/${default.pname}/Makefile"
    '';

    # Allow shell compisition.
    passthru.shellHook = shellHook;
  };
in

rec {
  inherit default;

  shell = {
    mkInternal = mkWikiShellFn { isExternalShell = false; };
    mkExternal = mkWikiShellFn { isExternalShell = true; };
  };
}
