{
  lib,
  stdenvNoCC,
  makeWrapper,
  python3,
  imagemagick,
  lutgen,
  inputs,
}:

let
  # Not pkgs.noctalia: that embeds config.toml, which references pkgs.nocwall.
  noctalia = inputs.noctalia.packages.${stdenvNoCC.hostPlatform.system}.default;
in

stdenvNoCC.mkDerivation {
  pname = "nocwall";
  version = "0.1.0";

  src = ./nocwall;

  nativeBuildInputs = [ makeWrapper ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    NOCWALL_NOCTALIA_ELF=${noctalia}/bin/.noctalia-wrapped \
    PYTHONPATH=src ${python3}/bin/python3 -m unittest discover -s tests -t . -q
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/nocwall $out/bin
    cp -r src/nocwall $out/share/nocwall/

    makeWrapper ${python3}/bin/python3 $out/bin/nocwall \
      --add-flags "-m nocwall" \
      --set PYTHONPATH "$out/share/nocwall" \
      --set NOCWALL_NOCTALIA_ELF "${noctalia}/bin/.noctalia-wrapped" \
      --prefix PATH : ${
        lib.makeBinPath [
          imagemagick
          lutgen
          noctalia
        ]
      }
    runHook postInstall
  '';

  meta = {
    description = "Sort wallpapers by palette and recolor them to the active noctalia scheme";
    mainProgram = "nocwall";
  };
}
