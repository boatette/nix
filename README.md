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
    │   ├── constants.nix values every class can read
    │   └── types/
    │       ├── base.nix
    │       └── desktop.nix
    ├── services/      systemd stuff
    ├── programs/
    └── users/
```

## Installing

Build the image on a working machine. `iso-full` bakes the current `aspire` closure into the image, so the install needs almost no network; `iso` is a plain installer.

```bash
nix build .#iso-full
sudo cp result/iso/*.iso /dev/[disk]
```

Build it from the revision you intend to install — the baked closure is only reused
if `flake.lock` matches.

1. Set up the ISO environment:

   ```bash
   sudo -i
   nmtui
   ```

2. Partition, format and mount. Print the script and read it first:

   ```bash
   disko --mode destroy,format,mount --flake /etc/nixos-config#[host] --dry-run
   ```

   Drop `--dry-run` to do it.

3. Install:

   ```bash
   nixos-install --flake /etc/nixos-config#[host]
   ```

4. Clone the repo to where it lives after the reboot:

   ```bash
   mkdir -p /mnt/home/[user]
   git clone https://github.com/boatette/nix.git /mnt/home/[user]/nix
   ```

5. Set the user password and fix ownership:

   ```bash
   nixos-enter --root /mnt -c 'passwd [user]'
   chown -R 1000:100 /mnt/home/[user]
   ```

6. Reboot.

<details>
<summary>From a stock or stale ISO</summary>

Without the baked closure the install builds and downloads on a tmpfs root, so it needs the job bounds and cachix keys to keep ram usage down:

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:boatette/nix#[host] --dry-run
nixos-install --flake github:boatette/nix#[host] --option max-jobs 3 --option cores 4 --option extra-substituters "https://nix-community.cachix.org https://noctalia.cachix.org" --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
```

</details>
