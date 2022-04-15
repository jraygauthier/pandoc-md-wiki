{ lib, buildPythonPackage, click, pyyaml, nsf-shc-nix-lib}:

buildPythonPackage rec  {
  pname = "pmw-tools";
  version = "0.0.0";
  src = ./.;
  buildInputs = [];

  propagatedBuildInputs = [
    click
    pyyaml
  ];

  doCheck = false;

  checkPhase = ''
    mypy .
    pytest .
    flake8
  '';

  postInstall =  with nsf-shc-nix-lib; ''
    ${nsfShC.pkg.installClickExesBashCompletion [
      "pmw-tools"
    ]}
  '';
}
