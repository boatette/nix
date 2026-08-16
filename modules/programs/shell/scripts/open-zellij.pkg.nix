{
  writeShellApplication,
  zellij,
  zoxide,
  fzf,
}:

writeShellApplication {
  name = "open-zellij";
  meta.description = "pick a directory with fzf, then attach or start a zellij session there";

  runtimeInputs = [
    zellij
    zoxide
    fzf
  ];

  bashOptions = [ ];
  text = builtins.readFile ./open-zellij.sh;
}
