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

`iso-full` bakes the current `aspire` closure into the image, so the install needs almost no network; `iso` is a plain installer. Build it from the revision you intend to install, the baked closure is only reused if `flake.lock` matches.

```bash
nix build .#iso-full
sudo cp result/iso/*.iso /dev/[disk]
sync
```

Both images carry the flake at `/etc/nixos-config`, a symlink to the store path the image was built from. That is what the commands below install from, so the install cannot drift from the image.

1. Set up the ISO environment:

   ```bash
   sudo -i
   nmtui
   ```

2. Partition, format and mount. `modules/hosts/[host]/disko.nix` names a specific `/dev/disk/by-id/...`, check it is the disk in this machine before running anything. Print the script and read it first:

   ```bash
   disko --mode destroy,format,mount --flake /etc/nixos-config#[host] --dry-run
   ```

   Drop `--dry-run` to do it. It destroys the disk it names.

3. Install. It asks for the root password at the end:

   ```bash
   nixos-install --flake /etc/nixos-config#[host]
   ```

4. Put the repo where it lives after the reboot. `~/nix` is set as a constant, which the rebuild aliases and nvim both bake in:

   ```bash
   mkdir -p /mnt/home/[user]
   git clone https://github.com/boatette/nix.git /mnt/home/[user]/nix
   ```

   No network, or an image built from a revision that is not `origin/master`? Copy the tree the image already carries instead. See below.

5. Set the user password and fix ownership:

   ```bash
   nixos-enter --root /mnt -c 'passwd [user]'
   chown -R 1000:100 /mnt/home/[user]
   ```

6. Reboot.

<details>
<summary>Step 4 without a clone</summary>

`/etc/nixos-config` is the tree the image was built from, so it can be copied out instead. Unlike a clone it is guaranteed to match the baked closure:

```bash
mkdir -p /mnt/home/[user]
cp -rL --no-preserve=mode /etc/nixos-config /mnt/home/[user]/nix
```

The copy has no `.git`. Rebuilds do not care, but reattach it once there is a network:

```bash
cd ~/nix
git init -b master
git remote add origin https://github.com/boatette/nix.git
git fetch origin
git reset --mixed origin/master
git branch -u origin/master
git status   # should be empty
```

</details>

<details>
<summary>From a stock or stale ISO</summary>

Without the baked closure the install builds and downloads on a tmpfs root, so it needs the job bounds and cachix keys to keep ram usage down:

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:boatette/nix#[host] --dry-run
nixos-install --flake github:boatette/nix#[host] --option max-jobs 3 --option cores 4 --option extra-substituters "https://nix-community.cachix.org https://noctalia.cachix.org" --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
```

</details>
