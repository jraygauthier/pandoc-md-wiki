{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "pandoc-ext-list-table";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "pandoc-ext";
    repo = "list-table";
    tag = "v${version}";
    hash = "sha256-pynEW3y8KhH3CPJeyDmp7+rdwZFnS+YTI/s7nllI47k=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D ./*.lua -t $out

    runHook postInstall
  '';

  meta = {
    description = "List tables for Pandoc";
    homepage = "https://github.com/pandoc-ext/list-table";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jraygauthier ];
    platforms = lib.platforms.all;
  };
}
