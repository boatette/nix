{
  writeShellApplication,
  rsync,
  util-linux,
  coreutils,
  gnugrep,
}:
writeShellApplication {
  name = "ssd";
  meta.description = "mirror home to the SSD, and back";

  runtimeInputs = [
    rsync
    util-linux
    coreutils
    gnugrep
  ];

  bashOptions = [ ];
  text = builtins.readFile ./ssd.sh;
}
