{ lib, buildPythonPackage, click, pyyaml }:

buildPythonPackage rec  {
  pname = "pmw-tools";
  version = "0.0.0";
  src = ./.;
  buildInputs = [];
  propagatedBuildInputs = [
    click
    pyyaml
  ];
}
