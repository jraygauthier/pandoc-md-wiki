{ lib
, stdenv
, makeBinaryWrapper
# , diagrams-builder
, gnumake
, graphviz
, jdk
, jq
, lua5_4
, nix-gitignore
, pandoc
, pandoc-ext-diagram
, pandoc-ext-list-table
, plantuml
, xdg-utils
, yq
}:
stdenv.mkDerivation rec {
  version = "0.0.0";
  pname = "pandoc-md-wiki";
  name = "${pname}-${version}";

  passthru = {
    inherit pname;
  };

  src = nix-gitignore.gitignoreSource [] ./.;

  # TODO: Patch the makefile.

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildInputs = [
    # diagrams-builder
    gnumake
    jq
    xdg-utils
    yq
    plantuml
    graphviz
  ];

  preBuild = ''
    mkdir -p ./bin
    makeWrapper "${pandoc}/bin/pandoc" ./bin/pandoc-md-wiki \
      --prefix PATH : "${lib.makeBinPath [
        lua5_4
        graphviz
        jdk
        plantuml
      ]}" \
      --add-flags '--lua-filter=${pandoc-ext-list-table}/list-table.lua' \
      --add-flags '--lua-filter=${pandoc-ext-diagram}/diagram.lua'



    export "PATH=$PWD/bin:$PATH"
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    install ./bin/pandoc-md-wiki "$out/bin/pandoc-md-wiki"

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
