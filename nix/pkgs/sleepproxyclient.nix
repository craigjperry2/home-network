{
  pkgs,
  lib,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.dnspython ps.netifaces]);
in
  pkgs.stdenv.mkDerivation {
    pname = "sleepproxyclient";
    version = "unstable-2023-11-20";

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

      # Increase discovery timeout from 1s to 5s to help with cross-subnet reflection
      sed -i 's/timeout=1/timeout=5/g' $out/bin/sleepproxyclient

      # Ensure it uses the correct python interpreter
      sed -i "1i#!${python}/bin/python3" $out/bin/sleepproxyclient
      chmod +x $out/bin/sleepproxyclient

      wrapProgram $out/bin/sleepproxyclient \
        --prefix PATH : ${lib.makeBinPath [python]}
    '';
  }
