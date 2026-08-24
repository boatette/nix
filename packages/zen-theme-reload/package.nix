{ writers }:

writers.writePython3Bin "zen-theme-reload" { } (builtins.readFile ./reload.py)
