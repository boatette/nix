{
  coreutils,
  findutils,
  git,
  gnugrep,
  gnused,
  inputs,
  writeShellApplication,
}:
let
  inherit (inputs.self.constants) flakeDir;
in
writeShellApplication {
  name = "spotbye-bump";
  meta.description = "Add a downloaded SpotBye AppImage to the store, point the spotbye package at it and commit the bump";

  runtimeInputs = [
    coreutils
    findutils
    git
    gnugrep
    gnused
  ];

  runtimeEnv = {
    FLAKE = flakeDir;
    PACKAGE = "${flakeDir}/packages/spotbye/package.nix";
  };

  text = builtins.readFile ./spotbye-bump.sh;
}
