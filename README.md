# nix#redux

> [!NOTE]
> README still wip, just used as personal notes.

for steam to work, run

```bash
steam -cef-disable-gpu-compositing
```

may also still need to remove ~/.steam and/or ~/.local/share/Steam/, then open normally to load millenium

first build:

```bash
sudo nixos-rebuild boot --flake ~/nix#redux --options experimental-features "nix-command flakes"
```
