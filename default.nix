{ stdenv
, makeWrapper
, jdk
, plantuml
, graphviz
, pandoc
, lua5_3
, diagrams-builder
, gnumake
, xdg_utils
}:

stdenv.mkDerivation rec {
  version = "0.0.0";
  pname = "pandoc-md-wiki";
  name = "${pname}-${version}";

  passthru = {
    inherit pname;
  };

  src = ./.;

  # TODO: Patch the makefile.

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    jdk
    plantuml
    graphviz
    pandoc
    # For experimenting with pandoc native lua filters.
    lua5_3

    diagrams-builder
    gnumake
    xdg_utils
  ];

  installPhase = ''
    mkdir -p "$out/share/${pname}"
    find . -mindepth 1 -maxdepth 1 -exec mv -t "$out/share/${pname}" {} +
  '';

  meta = {
    description = ''
      A simple markdown wiki build tool based on pandoc tailored to
      the needs of development teams.
    '';
  };
}
