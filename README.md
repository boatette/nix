# nix#redux

> [!NOTE]
> README still wip, just used as personal notes.

for steam to work, run

```bash
steam -cef-disable-gpu-compositing
```

first build:

```bash
sudo nixos-rebuild boot --flake ~/nix#redux --options experimental-features "nix-command flakes"
```
