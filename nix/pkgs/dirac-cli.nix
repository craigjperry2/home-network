{
  lib,
  buildNpmPackage,
  fetchzip,
  nodejs_24,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildNpmPackage {
  pname = "dirac-cli";
  version = "0.3.44";

  nodejs = nodejs_24;

  src = fetchzip {
    url = "https://registry.npmjs.org/dirac-cli/-/dirac-cli-0.3.44.tgz";
    hash = "sha256-ooMfVhPIH8SDD1IGAkry4wjqavX3QlFYZw43poPAKj4=";
  };

  postPatch = ''
        cp ${./dirac-cli-package-lock.json} package-lock.json

        python - <<'PY'
    import json
    from pathlib import Path

    path = Path("package.json")
    data = json.loads(path.read_text())
    data.pop("man", None)
    path.write_text(json.dumps(data, indent=2) + "\n")
    PY
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
