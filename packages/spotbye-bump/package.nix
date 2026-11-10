{
  coreutils,
  findutils,
  gnugrep,
  gnused,
  inputs,
  writeShellApplication,
}:
writeShellApplication {
  name = "spotbye-bump";
  meta.description = "Add a downloaded SpotBye AppImage to the store and point the spotbye package at it";

  runtimeInputs = [
    coreutils
    findutils
    gnugrep
    gnused
  ];

  runtimeEnv.PACKAGE = "${inputs.self.constants.flakeDir}/packages/spotbye/package.nix";

  text = builtins.readFile ./spotbye-bump.sh;
}
