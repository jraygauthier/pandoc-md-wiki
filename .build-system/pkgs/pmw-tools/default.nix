{ lib, buildPythonPackage
, mypy, pytest, flake8, ipython
, click, pyyaml
, fromNixShell ? false }:

buildPythonPackage rec  {
  pname = "pmw-tools";
  version = "0.0.0";
  src = ./.;
  buildInputs = [];
  checkInputs = [
    mypy
    pytest
    flake8
  ] ++ lib.optionals fromNixShell [
    ipython
  ];
  propagatedBuildInputs = [
    click
    pyyaml
  ];
}
