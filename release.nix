{ pkgs ? null } @ args:

let
  pkgs = (import ./.nix/release.nix {}).ensurePkgs args;
in

with pkgs;

let
  default = callPackage ./. {
    # Broken in 19.09. Fallback to 19.03.
    # diagrams-builder = pkgs1903.diagrams-builder;
  };
  pandoc-md-wiki-vscode-tools =
    callPackage ./.build-system/vscode {};

  mkWikiShellFn = {isExternalShell}: {withVscodeSupport, withPdfSupport}: mkShell rec {
    inputsFrom = [ default ];

    buildInputs = []
      ++ lib.optional withVscodeSupport pandoc-md-wiki-vscode-tools
      # Minimal requirement to get the `pdflatex` command required by
      # pandoc for pdf output.
      ++ lib.optional withPdfSupport (texlive.combined.scheme-basic);

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
