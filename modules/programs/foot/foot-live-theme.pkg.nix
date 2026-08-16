{
  writeShellApplication,
  gnugrep,
  procps,
  coreutils,
}:

writeShellApplication {
  name = "foot-live-theme";
  meta.description = "Re-apply the noctalia colour scheme to every running foot";

  runtimeInputs = [
    gnugrep
    procps
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./foot-live-theme.sh;
}
