{
  writeShellApplication,
  imagemagick,
  findutils,
}:

writeShellApplication {
  name = "prune-small";
  meta.description = "list or delete wallpapers below a minimum resolution";

  runtimeInputs = [
    imagemagick
    findutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./prune-small.sh;
}
