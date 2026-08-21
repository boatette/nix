{
  writeShellApplication,
  bash,
  foot,
  coreutils,
}:
writeShellApplication {
  name = "footclient-themed";
  meta.description = "footclient with the current colours";

  runtimeInputs = [
    bash
    foot
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./footclient-themed.sh;
}
