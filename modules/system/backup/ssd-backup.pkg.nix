{
  writeShellApplication,
  rsync,
  util-linux,
  coreutils,
}:

writeShellApplication {
  name = "ssd-backup";
  meta.description = "Mirror home data to the external SSD";

  runtimeInputs = [
    rsync
    util-linux
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./ssd-backup.sh;
}
