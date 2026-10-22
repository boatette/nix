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

1. When reinstalling, back up first. The `backup` module mirrors home's data, `~/.ssh`, `~/.claude` and the browser profiles to `/mnt/storage/bak` daily, but run it once more with the browsers closed. Anything not listed in `packages/ssd/ssd.sh` is lost with the disk:

   ```bash
   baknow       # or, before the running system has the current script:
   nix run ~/nix#ssd -- backup
   ```

2. Build the image and write it to a stick:

   ```bash
   nix build .#iso
   sudo cp result/iso/*.iso /dev/sdX && sync
   ```

   For a Ventoy drive, copy the `.iso` onto its data partition instead, then `sync`. Check it is mounted as `exfat`, not `fuseblk` (`mount | grep -i ventoy`), as the fuse driver is far slower.

3. Put the firmware into **Setup Mode** (clear the Secure Boot keys). The installer and the fresh install are both unsigned, so old keys would refuse to boot them. From a running system, `boot.loader.timeout` is 0: **hold Space** during boot to reach "Reboot Into Firmware Interface". `install-host` checks this for hosts with Secure Boot, and offers to reboot into the firmware if it was missed.

4. Boot the stick and run:

   ```bash
   sudo install-host          # pick a host from a menu
   sudo install-host [host]   # or name it
   ```

   It opens `nmtui` if there is no network, checks this machine has the disk `modules/hosts/[host]/disko.nix` names, shows what it will erase, and waits for you to type the host name. Then it partitions (prompting for the LUKS passphrase, which has no recovery until step 5), installs, and asks for each user's password. On a host with impermanence, root is locked, so `nixos-install` doesn't ask for a root password, and each user's password is hashed into `/persist/passwords/[user]` instead of `/etc/shadow`. `--dry-run` shows all of that, plus disko's script, without touching anything.

5. Reboot and log in. Reconnect to Wi-Fi with `nmtui`, because the installer's connection isn't carried over. With the SSD plugged in, `ssd-restore` copies the backup back at the first login without overwriting anything. Wait until `systemctl --user status ssd-restore` shows it has finished, so the old `~/.ssh` key is back before the next command. Its notification can fire before the session's notification daemon is running. Then run:

   ```bash
   finish-install
   ```

   It waits for the Secure Boot keys to be enrolled, which takes one more reboot, then binds the disk to the TPM and creates a recovery key. It logs `gh` in to GitHub with a one-time code you enter in a browser on any device. The repo is private, so it clones it to `~/nix` over SSH. It uses the restored `~/.ssh/id_ed25519` if there is one. Otherwise it creates a key and `gh` adds it to GitHub; if that fails, it prints the key and waits for you to add it. Rerun it whenever it asks; `finish-install --check` shows what is left.

   **Write the recovery key down somewhere that is not this laptop.**

What each host needs is read from its own config (`modules/system/settings/install.nix`): its disko disks, whether it uses Secure Boot, which LUKS devices unlock with the TPM, which users have no password, where password files go, and whether root is locked. A reminder that can't be derived goes in the host, and both commands print it:

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

[lanzaboote](https://github.com/nix-community/lanzaboote) (`modules/system/secure-boot.nix`) replaces systemd-boot and signs every generation on rebuild. Keys live in `/var/lib/sbctl` (kept in `/persist`), and a copy of their enrollment files stays on the ESP, so a firmware key reset is re-enrolled on the next boot. Nothing here needs redoing short of a reinstall.

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

## Impermanence

`modules/system/impermanence.nix` gives aspire a fresh, empty `/` on every boot. Before the root is mounted, an initrd service moves the old `root` subvolume to `old_roots/[timestamp]` and creates a new one. Archived roots are deleted after 30 days. `/nix`, `/home`, `/var/log` and `/persist` are their own subvolumes and are left alone. [preservation](https://github.com/nix-community/preservation) bind-mounts or symlinks the system state that has to survive from `/persist`. That includes the machine-id, `/var/lib/nixos`, the Secure Boot keys, NetworkManager, Bluetooth and systemd timers.

Users are immutable (`users.mutableUsers = false`), so `passwd` doesn't work. Change a password with:

```bash
mkpasswd | sudo tee /persist/passwords/[user]
```

If a setting resets after a reboot, it lives somewhere that isn't persisted. Copy it back from the previous root, then add its path to the preserve lists:

```bash
sudo mount -o subvol=/ /dev/mapper/cryptroot /mnt
ls /mnt/old_roots
```

`impermanence.wipe = false;` stops the wiping and leaves everything else in place.

## Known Issues

### Steam

Steam's embedded CEF browser can fail to start, leaving a blank client window. `-cef-disable-gpu` is applied declaratively in `modules/programs/gaming.nix`; if the client still fails, clear its local state:

```bash
rm -rf ~/.steam ~/.local/share/Steam
```
