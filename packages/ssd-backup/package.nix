{
  writeShellApplication,
  rsync,
  util-linux,
  coreutils,
}:
writeShellApplication {
  name = "ssd-backup";
  meta.description = "mirror home to the SSD";

  runtimeInputs = [
    rsync
    util-linux
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./ssd-backup.sh;
}
