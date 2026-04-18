{
  pkgs,
  lib,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.dnspython]);
in
  pkgs.stdenv.mkDerivation {
    pname = "sleepproxyclient";
    version = "unstable-2025-07-21";

    src = pkgs.fetchFromGitHub {
      owner = "awein";
      repo = "SleepProxyClient";
      rev = "a3a55d083cef0fd00aa3ba38d603d1088bf71a7a";
      sha256 = "0lxwivab7slbmjkmwl7s7xmlfn8zbgraz8sayg1gpzs2k9hxqm2m";
    };

    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      mkdir -p $out/bin
      cp sleepproxyclient.py $out/bin/sleepproxyclient
      chmod +x $out/bin/sleepproxyclient
      wrapProgram $out/bin/sleepproxyclient \
        --set PATH ${lib.makeBinPath [python]}
    '';
  }
