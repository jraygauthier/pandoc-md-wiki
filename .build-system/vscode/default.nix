{ stdenv
, makeWrapper
, xdg_utils
, gnused
, coreutils
, gnumake
}:

stdenv.mkDerivation {
  name = "pandoc-md-wiki-vscode-tools-0.0.0";
  src = ./.;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    xdg_utils
    gnused
    coreutils
  ];

  buildPhase = "true";

  installPhase = ''
    mkdir -p "$out"
    mv -t "$out/" "./bin/"

    mkdir -p "$out/bin"
    for cmd in $(find "$out/bin" -mindepth 1 -maxdepth 1); do
      wrapProgram "$cmd" \
        --prefix PATH : "$PATH"
    done
  '';
}