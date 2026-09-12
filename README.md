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
    │   └── iso/            builder for custom iso
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

`iso` is a minimal installer that carries the flake at `/etc/nixos-config` and this config's substituters, so the install pulls from the caches rather than building. Build it from the revision you intend to install.

1. Build the image and write it to a stick:

   ```bash
   nix build .#iso
   sudo cp result/iso/*.iso /dev/sdX && sync
   ```

   For a Ventoy drive, copy the `.iso` onto its data partition instead, then `sync`. Check it is mounted as `exfat`, not `fuseblk` (`mount | grep -i ventoy`), as the fuse driver is far slower.

2. Put the firmware into **Setup Mode** (clear the Secure Boot keys). The installer and the fresh install are both unsigned, so old keys would refuse to boot them. From a running system, `boot.loader.timeout` is 0: **hold Space** during boot to reach "Reboot Into Firmware Interface".

3. Boot the stick and install:

   ```bash
   sudo -i
   nmtui
   disko --mode destroy,format,mount --flake /etc/nixos-config#[host] --dry-run
   ```

   `modules/hosts/[host]/disko.nix` names a specific `/dev/disk/by-id/...`. Read the printed script, check it is the disk in this machine, then drop `--dry-run`. It destroys the disk it names and prompts for the LUKS passphrase, which has no keyfile and no recovery without it.

   ```bash
   nixos-install --flake /etc/nixos-config#[host]
   nixos-enter --root /mnt -c 'passwd [user]'
   reboot
   ```

4. The first boot generates the Secure Boot keys and stages them on the ESP. Reboot once more and systemd-boot enrolls them. Confirm with:

   ```bash
   bootctl status   # Secure Boot: enabled (user)
   ```

5. Enroll the TPM so the disk unlocks without the passphrase:

   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7
   sudo systemd-cryptenroll --recovery-key
   ```

   **Write the recovery key down somewhere that is not this laptop.**

6. Clone the repo to `~/nix`, where the rebuild aliases and nvim expect it:

   ```bash
   git clone https://github.com/boatette/nix.git ~/nix
   ```

### Install from a stock ISO

An upstream NixOS ISO has neither the flake nor the caches, and installs onto a tmpfs root, so it needs the substituters and job bounds passed in:

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

[lanzaboote](https://github.com/nix-community/lanzaboote) (`modules/system/secure-boot.nix`) replaces systemd-boot and signs every generation on rebuild. Keys live in `/var/lib/sbctl`, and a copy of their enrollment files stays on the ESP, so a firmware key reset is re-enrolled on the next boot. Nothing here needs redoing short of a reinstall.

The TPM is bound to PCR 7 alone. It refuses to release the key if Secure Boot is disabled or the keys are swapped, but survives kernel and generation changes.

> [!TIP]
>
> If a firmware update invalidates the enrollment, the passphrase prompt simply comes back, it is not a lockout. Re-enroll with:
>
> ```bash
> sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-partlabel/disk-main-root --tpm2-device=auto --tpm2-pcrs=7
> ```
>
> If the machine refuses to boot at all, disable Secure Boot in the firmware, boot, and `sbctl reset`.

## Known Issues

### Steam

Steam's embedded CEF browser can fail to start, leaving a blank client window. `-cef-disable-gpu` is applied declaratively in `modules/programs/gaming.nix`; if the client still fails, clear its local state:

```bash
rm -rf ~/.steam ~/.local/share/Steam
```
