# NixOS Config

NixOS configuration for umbriel + noctalia.

## Layout

```
~/nix/
├── flake.nix          generated
├── packages/
└── modules/
    ├── nix/           how the flake itself is assembled
    ├── hosts/
    ├── system/        aspects that are not a program
    │   ├── settings/    everything every machine gets
    │   ├── session/     the graphical session
    │   ├── constants/   values every class can read
    │   └── types/
    │       ├── base.nix
    │       └── desktop.nix
    ├── services/      systemd stuff
    ├── programs/
    └── users/
```

## Installing

1. Set up the ISO environment:

   ```bash
   sudo -i
   nmtui
   export NIX_CONFIG="experimental-features = nix-command flakes"
   ```

2. Partition, format and mount. Print the script and read it first:

   ```bash
   nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:boatette/nix#[host] --dry-run
   ```

   Drop `--dry-run` to do it.

3. Clone the repo to where it lives after the reboot:

   ```bash
   mkdir -p /mnt/home/[user]
   nix run nixpkgs#git -- clone https://github.com/boatette/nix.git /mnt/home/[user]/nix
   ```

4. Install:

   ```bash
   nixos-install --flake /mnt/home/[user]/nix#[host] --option max-jobs 3 --option cores 4 --option extra-substituters "https://nix-community.cachix.org https://noctalia.cachix.org" --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
   ```

   Job bounds and cachix keep ram usage down; neither is required.

   ```bash
   grep -m1 nixos-install /mnt/home/[user]/nix/README.md > sh
   ```

5. Set the user password and fix ownership:

   ```bash
   nixos-enter --root /mnt -c 'passwd [user]'
   chown -R 1000:100 /mnt/home/[user]
   ```

6. Reboot.
