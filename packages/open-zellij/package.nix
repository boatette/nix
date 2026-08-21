{
  writeShellApplication,
  zellij,
  zoxide,
  fzf,
}:
writeShellApplication {
  name = "open-zellij";
  meta.description = "pick a directory, open zellij there";

  runtimeInputs = [
    zellij
    zoxide
    fzf
  ];

  bashOptions = [ ];
  text = builtins.readFile ./open-zellij.sh;
}
