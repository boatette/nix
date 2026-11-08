{
  writeShellApplication,
  rsync,
  util-linux,
  coreutils,
  gnugrep,
  libnotify,
}:
writeShellApplication {
  name = "ssd";
  meta.description = "mirror home to the SSD, and back";

  runtimeInputs = [
    rsync
    util-linux
    coreutils
    gnugrep
    libnotify
  ];

  bashOptions = [
    "nounset"
    "pipefail"
  ];
  text = builtins.readFile ./ssd.sh;
}
