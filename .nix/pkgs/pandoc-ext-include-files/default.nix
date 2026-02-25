{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "pandoc-ext-include-files";
  version = "0-unstable-2026-01-06";

  src = fetchFromGitHub {
    owner = "pandoc-ext";
    repo = "include-files";
    rev = "0d2280517d1d73544739593e549ef7567ce968b5";
    hash = "sha256-SflyatsY8TZjnkFIOHgnLixI5x03c+CA2KNAnPKJu4k=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D ./*.lua -t $out

    runHook postInstall
  '';

  meta = {
    description = "Filter to include other files in the document";
    homepage = "https://github.com/pandoc-ext/include-files";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jraygauthier ];
    platforms = lib.platforms.all;
  };
}
