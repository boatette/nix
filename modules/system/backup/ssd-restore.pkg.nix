{
  writeShellApplication,
  rsync,
  util-linux,
  coreutils,
}:

writeShellApplication {
  name = "ssd-restore";
  meta.description = "Restore home data from the external SSD on a fresh install";

  runtimeInputs = [
    rsync
    util-linux
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./ssd-restore.sh;
}
