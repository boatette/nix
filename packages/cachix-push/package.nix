{
  writeShellApplication,
  cachix,
  nix,
  coreutils,
  findutils,
  gnugrep,
}:
writeShellApplication {
  name = "cachix-push";
  meta.description = "push store paths to the binary cache, minus what we may not redistribute";

  runtimeInputs = [
    cachix
    nix
    coreutils
    findutils
    gnugrep
  ];

  text = builtins.readFile ./cachix-push.sh;
}
