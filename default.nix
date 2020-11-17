{ stdenv
, makeWrapper
#, diagrams-builder
, gnumake
, graphviz
, jdk
, jq
, lua5_3
, pandoc
, plantuml
, xdg_utils
, yq
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

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    # diagrams-builder
    gnumake
    graphviz
    jdk
    jq
    lua5_3 # For experimenting with pandoc native lua filters.
    pandoc
    plantuml
    xdg_utils
    yq
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
