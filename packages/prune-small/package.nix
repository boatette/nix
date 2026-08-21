{
  writeShellApplication,
  imagemagick,
  findutils,
}:
writeShellApplication {
  name = "prune-small";
  meta.description = "delete undersized wallpapers";

  runtimeInputs = [
    imagemagick
    findutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./prune-small.sh;
}
