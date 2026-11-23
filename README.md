# NixOS Config

NixOS for one laptop, `aspire`, on [umbriel](https://github.com/noctalia-dev/umbriel) with [noctalia](https://github.com/noctalia-dev/noctalia-shell) as its shell. [AGENTS.md](AGENTS.md) explains how the flake is put together.

## Installing

1. When reinstalling, back up first. The `backup` module mirrors home's data, `~/.ssh`, `~/.claude` and the browser profiles to `/mnt/storage/bak` daily; run it once more with the browsers closed. Anything not listed in `packages/ssd/ssd.sh` is lost with the disk:

   ```bash
   baknow
   ```

2. Put the firmware into **Secure Boot Setup Mode** (clear its keys); the fresh install is unsigned. `boot.loader.timeout` is 0, so **hold Space** during boot to reach "Reboot Into Firmware Interface".

3. Boot the official NixOS minimal ISO in UEFI mode and run:

   ```bash
   nix --extra-experimental-features 'nix-command flakes' run github:boatette/nix#install-host
   ```

   It opens `nmtui` when offline, checks this machine has the disk `modules/hosts/aspire/disko.nix` names, shows what it will erase and waits for you to type `aspire`. Then it partitions (asking for the LUKS passphrase, which has no recovery until step 4), installs, and asks for the user's password. `--dry-run` shows the plan and disko's script without touching anything.

   Until petal has a remote, its input comes from the SSD's backup:

   ```bash
   sudo mount /dev/disk/by-id/usb-Samsung_PSSD_T7_Shield_*-part1 /media
   nix --extra-experimental-features 'nix-command flakes' run github:boatette/nix#install-host -- -- --override-input petal path:/media/bak/Projects/petal
   ```

4. Reboot and log in. With the SSD plugged in, `ssd-restore` copies the backup back at the first login without overwriting anything; wait until `systemctl --user status ssd-restore` shows it finished, so `~/.ssh` is back. Then run:

   ```bash
   finish-install
   ```

   It waits for the Secure Boot keys to be enrolled (one more reboot), binds the disk to the TPM, creates a recovery key, logs `gh` in to GitHub and clones the flake to `~/nix` over SSH. Rerun it whenever it asks; `finish-install --check` shows what is left.

   **Write the recovery key down somewhere that is not this laptop.**

## Secure Boot

[lanzaboote](https://github.com/nix-community/lanzaboote) signs every generation. Its keys live in `/var/lib/sbctl` (kept in `/persist`), and their enrollment files stay on the ESP, so a firmware key reset is re-enrolled on the next boot. The TPM is bound to PCR 7 alone: it refuses the key if Secure Boot is off or the keys change, but survives kernel and generation changes.

> [!TIP]
>
> If a firmware update invalidates the enrollment, the passphrase prompt comes back; it is not a lockout. Re-enroll with `finish-install --reenroll-tpm`. If the machine refuses to boot at all, disable Secure Boot in the firmware, boot, and `sbctl reset`.

## Impermanence

`/` is a fresh btrfs subvolume on every boot. `/nix`, `/home`, `/var/log` and `/persist` are kept, and system state that must survive is listed in `modules/system/impermanence.nix`. `impermanence.wipe = false;` stops the wiping.

Users are immutable, so `passwd` does nothing. Change a password with:

```bash
mkpasswd | sudo tee /persist/passwords/boatette
```

If a setting resets after a reboot, it lives somewhere that isn't persisted. Previous roots are kept for 30 days; copy it back from one, then add its path to the preserve lists:

```bash
sudo mount -o subvol=/ /dev/mapper/cryptroot /mnt
ls /mnt/old_roots
```

## Known Issues

### Steam

Steam's embedded browser can fail to start, leaving a blank client window. `-cef-disable-gpu` is set in `modules/programs/gaming.nix`; if the client still fails, clear its local state:

```bash
rm -rf ~/.steam ~/.local/share/Steam
```
