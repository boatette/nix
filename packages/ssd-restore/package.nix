{
  writeShellApplication,
  rsync,
  util-linux,
  coreutils,
}:
writeShellApplication {
  name = "ssd-restore";
  meta.description = "restore home from the SSD";

  runtimeInputs = [
    rsync
    util-linux
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./ssd-restore.sh;
}
