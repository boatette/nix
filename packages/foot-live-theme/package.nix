{
  writeShellApplication,
  gnugrep,
  procps,
  coreutils,
}:
writeShellApplication {
  name = "foot-live-theme";
  meta.description = "re-theme running foot";

  runtimeInputs = [
    gnugrep
    procps
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./foot-live-theme.sh;
}
