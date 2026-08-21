{
  lib,
  writers,
  symlinkJoin,
  makeWrapper,
  git,
  lua5_4,
}:

let
  raw = writers.writePython3Bin "omarchy-import" {
    flakeIgnore = [
      "E501"
      "E203"
      "W503"
    ];
  } (builtins.readFile ./omarchy_import.py);
in
symlinkJoin {
  name = "omarchy-import";
  paths = [ raw ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/omarchy-import \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          lua5_4
        ]
      } \
      --set-default OMARCHY_IMPORT_EXTRACTOR ${./extract_spec.lua}
  '';

  meta = {
    description = "import an omarchy theme as a noctalia palette, wallpaper folder and neovim entry";
    mainProgram = "omarchy-import";
  };
}
