# NixOS Config

NixOS configuration for a lightweight desktop on [aion](https://github.com/boatette/aion), a scrolling dwl-like compositor. Log in on tty1 to start it.

## Layout

```
~/nix/
├── flake.nix               generated
├── packages/
└── modules/
    ├── nix/                how the flake itself is assembled
    ├── hosts/
    │   ├── aspire/         the laptop
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

`iso` is a minimal installer that carries the flake at `/etc/nixos-config`, this config's substituters and `install-host`, so the install pulls from the caches rather than building. Build it from the revision you intend to install.

1. Build the image and write it to a stick:

   ```bash
   nix build .#iso
   sudo cp result/iso/*.iso /dev/sdX && sync
   ```

   For a Ventoy drive, copy the `.iso` onto its data partition instead, then `sync`. Check it is mounted as `exfat`, not `fuseblk` (`mount | grep -i ventoy`), as the fuse driver is far slower.

2. Put the firmware into **Setup Mode** (clear the Secure Boot keys). The installer and the fresh install are both unsigned, so old keys would refuse to boot them. From a running system, `boot.loader.timeout` is 0: **hold Space** during boot to reach "Reboot Into Firmware Interface". `install-host` checks this for hosts with Secure Boot, and offers to reboot into the firmware if it was missed.

3. Boot the stick and run:

   ```bash
   sudo install-host          # pick a host from a menu
   sudo install-host [host]   # or name it
   ```

   It opens `nmtui` if there is no network, checks this machine has the disk `modules/hosts/[host]/disko.nix` names, shows what it will erase, and waits for you to type the host name. Then it partitions (prompting for the LUKS passphrase, which has no recovery until step 4), installs and sets the user passwords. `--dry-run` shows all of that, plus disko's script, without touching anything.

4. Reboot, log in, and run:

   ```bash
   finish-install
   ```

   It waits for the Secure Boot keys to be enrolled, which takes one more reboot, then binds the disk to the TPM and creates a recovery key. The repo is private, so it also creates an SSH key, waits for you to add it to GitHub, and clones the repo to `~/nix`. Rerun it whenever it asks; `finish-install --check` shows what is left.

   **Write the recovery key down somewhere that is not this laptop.**

What each host needs is read from its own config (`modules/system/settings/install.nix`): its disko disks, whether it uses Secure Boot, which LUKS devices unlock with the TPM, and which users have no password. A reminder that can't be derived goes in the host, and both commands print it:

```nix
# modules/hosts/[host]/install.nix
{
  flake.modules.nixos.[host].install.notes = [ "..." ];
}
```

### Install a new machine

Boot the stick and run `sudo install-host [host]`. When the disk isn't found, it lists this machine's disks by their `/dev/disk/by-id` names. Copy the stick's flake somewhere writable, put the right disk in its `modules/hosts/[host]/disko.nix`, and install from the copy:

```bash
cp -r --no-preserve=mode /etc/nixos-config /tmp/nix
sudo install-host --flake /tmp/nix [host]
```

Make the same change in the clone once the machine is up, and commit it.

## Secure Boot

[lanzaboote](https://github.com/nix-community/lanzaboote) (`modules/system/secure-boot.nix`) replaces systemd-boot and signs every generation on rebuild. Keys live in `/var/lib/sbctl`, and a copy of their enrollment files stays on the ESP, so a firmware key reset is re-enrolled on the next boot. Nothing here needs redoing short of a reinstall.

The TPM is bound to PCR 7 alone. It refuses to release the key if Secure Boot is disabled or the keys are swapped, but survives kernel and generation changes.

> [!TIP]
>
> If a firmware update invalidates the enrollment, the passphrase prompt simply comes back, it is not a lockout. Re-enroll with:
>
> ```bash
> finish-install --reenroll-tpm
> ```
>
> If the machine refuses to boot at all, disable Secure Boot in the firmware, boot, and `sbctl reset`.

## Known Issues

### Steam

Steam's embedded CEF browser can fail to start, leaving a blank client window. `-cef-disable-gpu` is applied declaratively in `modules/programs/gaming.nix`; if the client still fails, clear its local state:

```bash
rm -rf ~/.steam ~/.local/share/Steam
```
