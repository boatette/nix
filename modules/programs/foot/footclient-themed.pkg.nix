{
  writeShellApplication,
  bash,
  foot,
  coreutils,
}:

writeShellApplication {
  name = "footclient-themed";
  meta.description = "footclient, pre-seeded with the current noctalia colours";

  runtimeInputs = [
    bash
    foot
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./footclient-themed.sh;
}
