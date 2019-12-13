{ nixpkgs ? import ./.nix/pinned-nixpkgs.nix {}
, withVscodeSupport ? false
, _isExternalShell ? false
}:

let
  lib = nixpkgs.lib;
  release = import ./release.nix { inherit nixpkgs; };
  pandoc-md-wiki-vscode-tools =
    nixpkgs.callPackage ./.build-system/vscode {};
in

nixpkgs.mkShell {
  inputsFrom = [ release ];

  buildInputs = []
    ++ lib.optional withVscodeSupport pandoc-md-wiki-vscode-tools;

  shellHook = lib.optionalString _isExternalShell ''
    export PANDOC_MD_WIKI_RELEASE_MAKEFILE="${release}/share/${release.pname}/Makefile"
  '';
}
