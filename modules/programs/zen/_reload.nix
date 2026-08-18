{ pkgs }:

pkgs.writers.writePython3Bin "zen-theme-reload" { flakeIgnore = [ "E501" ]; } (
  builtins.readFile ./reload.py
)
