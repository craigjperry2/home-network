{
  lib,
  stdenvNoCC,
  fetchurl,
  versionCheckHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.31.1";

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${finalAttrs.version}/agent-browser-darwin-arm64";
    hash = "sha256-/XrNF7MHH/f3WgPB7NMFAZWdnC0GO9qgWttvd6vyp78=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/agent-browser

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [versionCheckHook];
  versionCheckProgram = "${placeholder "out"}/bin/agent-browser";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Browser automation CLI for AI agents";
    homepage = "https://agent-browser.dev";
    downloadPage = "https://github.com/vercel-labs/agent-browser/releases";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
    platforms = ["aarch64-darwin"];
  };
})
