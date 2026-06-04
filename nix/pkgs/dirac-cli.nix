{
  lib,
  buildNpmPackage,
  fetchzip,
  nodejs_24,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  jq,
}:
buildNpmPackage {
  pname = "dirac-cli";
  version = "0.3.44";

  nodejs = nodejs_24;

  nativeBuildInputs = [jq];

  src = fetchzip {
    url = "https://registry.npmjs.org/dirac-cli/-/dirac-cli-0.3.44.tgz";
    hash = "sha256-ooMfVhPIH8SDD1IGAkry4wjqavX3QlFYZw43poPAKj4=";
  };

  postPatch = ''
    cp ${./dirac-cli-package-lock.json} package-lock.json

    ${jq}/bin/jq 'del(.man)' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  npmDepsHash = "sha256-Aqu59AdaFcknTofGdY+5O2apBkTbZSiVdvWP2b11VDQ=";
  dontNpmBuild = true;

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = ["HOME"];
  versionCheckProgram = "${placeholder "out"}/bin/dirac";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Autonomous coding agent CLI";
    homepage = "https://dirac.run";
    downloadPage = "https://www.npmjs.com/package/dirac-cli";
    license = lib.licenses.asl20;
    mainProgram = "dirac";
    platforms = lib.platforms.darwin;
  };
}
