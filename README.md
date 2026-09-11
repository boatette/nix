# NixOS Config

NixOS configuration for umbriel + noctalia.

## Layout

```
~/nix/
├── flake.nix               generated
├── packages/
└── modules/
    ├── nix/                how the flake itself is assembled
    ├── hosts/
    ├── system/             aspects that are not a program
    │   ├── settings/       everything every machine gets
    │   ├── session/        the graphical session
    │   ├── constants.nix   values every class can read
    │   └── types/
    │       ├── base.nix
    │       └── desktop.nix
    ├── services/           systemd stuff
    ├── programs/
    └── users/
```

## Installing

`iso` is a minimal installer at around **1.5GB**. It carries the flake and this config's substituters, so the install pulls prebuilt paths from the caches rather than building them. Build it from the revision you intend to install.

### Build the image

```bash
cd [flakeDir]
nix build .#iso
```

### Write it to a raw disk

```bash
sudo cp result/iso/*.iso /dev/[disk]
sync
```

### Write it to a Ventoy drive

Ventoy boots the `.iso` as a file, so drop it on the Ventoy data partition rather than writing to `/dev/[disk]`. Nothing to reformat; the boot menu picks it up.

```bash
rsync -h --progress result/iso/*.iso /run/media/[user]/Ventoy/
sync
```

`rsync` (and `cp`) return once the copy is in the page cache, not on the stick; `sync` is the real wait. `watch -d 'grep -E "Dirty|Writeback" /proc/meminfo'` shows that flush drain to zero. Check the partition mounted as `exfat`, not `fuseblk` (`mount | grep -i ventoy`), as the fuse driver is far slower.

### Install

The image carries the flake at `/etc/nixos-config`, a symlink to the store path the image was built from. That is what the commands below install from, so the install cannot drift from the image.

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

   The root partition is LUKS2. `disko` prompts for the passphrase while formatting; there is no keyfile and no way to recover the volume without it.

3. Install. It asks for the root password at the end:

   ```bash
   nixos-install --flake /etc/nixos-config#[host]
   ```

4. Put the repo where it lives after the reboot. `~/nix` is set as a constant, which the rebuild aliases and nvim both bake in:

   ```bash
   mkdir -p /mnt/home/[user]
   git clone https://github.com/boatette/nix.git /mnt/home/[user]/nix
   ```

   No network, or an image built from a revision that is not `origin/master`? [Copy the tree the image already carries instead.](#fetch-the-repo-without-a-clone)

5. Set the user password and fix ownership:

   ```bash
   nixos-enter --root /mnt -c 'passwd [user]'
   chown -R 1000:100 /mnt/home/[user]
   ```

6. Reboot. The passphrase prompt appears over the boot splash.

7. Hibernation is off until the swapfile offset is re-derived, because the LUKS2 header shifts every offset inside the mapper relative to the raw partition:

   ```bash
   sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
   ```

   Restore both lines in `modules/hosts/[host]/hardware.nix` with the value it prints, pointing `resumeDevice` at the mapper rather than the partition, then rebuild and test `systemctl hibernate` before trusting it.

### Fetch the repo without a clone

An alternative to step 4. `/etc/nixos-config` is the tree the image was built from, so it can be copied out instead. Unlike a clone it is guaranteed to match the revision the image was built from:

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

### Install from a stock ISO

An ISO built from this repo already carries the substituters below, so `nixos-install --flake /etc/nixos-config#[host]` is all you need. An upstream NixOS ISO does not, and it installs onto a tmpfs root, so it needs the caches and the job bounds to keep ram usage down:

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:boatette/nix#[host] --dry-run
nixos-install --flake github:boatette/nix#[host] --option max-jobs 3 --option cores 4 --option extra-substituters "https://nix-community.cachix.org https://noctalia.cachix.org" --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
```

> [!TIP]
>
> To avoid manually typing the cachix stuff
>
> ```bash
> curl -sL https://raw.githubusercontent.com/boatette/nix/master/README.md | grep -m1 '^nixos-install '
> ```

## Secure Boot

Secure Boot is handled by [lanzaboote](https://github.com/nix-community/lanzaboote), which replaces `systemd-boot` and signs each generation as a UKI. The module lives at `modules/system/secure-boot.nix` and is **not** imported by default: on a fresh install there are no signing keys yet, so enabling it would fail the bootloader install. Do it in this order.

1. Create the keys. They land in `/var/lib/sbctl`.

   ```bash
   sudo sbctl create-keys
   ```

2. Add `secure-boot` to the host's imports in `modules/hosts/[host]/configuration.nix`, rebuild, and check every generation got signed. The raw `...-bzImage.efi` is expected to be unsigned.

   ```bash
   sudo sbctl verify
   ```

3. Reboot into the firmware. `boot.loader.timeout` is 0, so **hold Space** during boot to reach the menu and its "Reboot Into Firmware Interface" entry. Then put the firmware into Setup Mode.

4. Boot back into NixOS and enroll:

   ```bash
   sudo sbctl enroll-keys --microsoft
   ```

   `--microsoft` matters here. This machine has an NVIDIA dGPU whose OptionROM is Microsoft-signed, and dropping those keys is a common way to end up unable to boot.

5. Reboot and confirm:

   ```bash
   bootctl status   # Secure Boot: enabled (user), TPM2 Support: yes
   ```

### TPM2 auto-unlock

Only after Secure Boot is enabled, PCR 7 measures Secure Boot state, so enrolling earlier just means the unlock fails and you get the passphrase prompt back.

```bash
sudo systemd-cryptenroll /dev/disk/by-id/[disk]-part2 --tpm2-device=auto --tpm2-pcrs=7
sudo systemd-cryptenroll /dev/disk/by-id/[disk]-part2 --recovery-key
```

PCR 7 alone is the right tradeoff: it refuses to release the key if Secure Boot is disabled or the keys are swapped, while surviving kernel and generation changes. PCR 0 would break on every firmware update, and PCR 11 changes on every rebuild.

**Write the recovery key down somewhere that is not this laptop.** The original passphrase keyslot survives enrollment, but if you lose both and the TPM is cleared the data is gone.

Then add `crypttabExtraOpts = [ "tpm2-device=auto" ];` to the LUKS `settings` in `modules/hosts/[host]/disko.nix`, rebuild, and confirm it unlocks without prompting.

> [!TIP]
>
> If a firmware update invalidates the enrollment, the passphrase prompt simply comes back, it is not a lockout. Re-enroll with `systemd-cryptenroll --wipe-slot=tpm2 ... --tpm2-device=auto --tpm2-pcrs=7`.
>
> If the machine refuses to boot at all after enrolling keys, disable Secure Boot in the firmware, boot, and `sbctl reset`.

## Known Issues

### Steam

Steam's embedded CEF browser can fail to start, leaving a blank client window. `-cef-disable-gpu` is applied declaratively in `modules/programs/gaming.nix`; if the client still fails, clear its local state:

```bash
rm -rf ~/.steam ~/.local/share/Steam
```
