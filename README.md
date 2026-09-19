# NixOS Config

NixOS configuration for umbriel + noctalia.

> [!NOTE]
>
> `dotfiles` branch contains raw configurations for inferior systems without nix

## Layout

```
~/nix/
├── flake.nix               generated
├── packages/
└── modules/
    ├── nix/                how the flake itself is assembled
    ├── hosts/
    │   ├── iso/            builder for custom iso
    │   └── vm/             the desktop as a qemu guest
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

   It opens `nmtui` if there is no network, checks this machine has the disk `modules/hosts/[host]/disko.nix` names, shows what it will erase, and waits for you to type the host name. Then it partitions (prompting for the LUKS passphrase, which has no recovery until step 4), installs, sets the user passwords and clones the repo to `~/nix`. `--dry-run` shows all of that, plus disko's script, without touching anything.

4. Reboot, log in, and run:

   ```bash
   finish-install
   ```

   It waits for the Secure Boot keys to be enrolled, which takes one more reboot, then binds the disk to the TPM and creates a recovery key. Rerun it whenever it asks; `finish-install --check` shows what is left.

   **Write the recovery key down somewhere that is not this laptop.**

What each host needs is read from its own config (`modules/system/settings/install.nix`): its disko disks, whether it uses Secure Boot, which LUKS devices unlock with the TPM, and which users have no password. A reminder that can't be derived goes in the host, and both commands print it:

```nix
# modules/hosts/[host]/install.nix
{
  flake.modules.nixos.[host].install.notes = [ "..." ];
}
```

### Install a new machine

Boot the stick and run `sudo install-host [host]`. When the disk isn't found, it lists this machine's disks by their `/dev/disk/by-id` names. Put the right one in `modules/hosts/[host]/disko.nix`, push, and install from GitHub rather than the stick's copy of the flake:

```bash
sudo install-host --flake github:boatette/nix [host]
```

### Install from a stock ISO

An upstream NixOS ISO has neither the flake nor `install-host`, so run it from GitHub. It passes the substituters, and the job bounds a tmpfs root needs, by itself:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:boatette/nix#install-host
```

## VM

`vm` (`modules/hosts/vm/`) is the desktop, `desktop` + `boatette` without aspire's hardware, as a QEMU guest. It runs straight off the host's `/nix/store`, so it builds from what is already there. Its root and `/home` live in `~/.local/share/nixos-vm/vm.qcow2` and persist between runs. Hosts that import `libvirt` get:

```bash
vm               # build and start it in a window, log in as boatette / vm
vm --headless    # no window, use vm-ssh
vm-ssh [cmd]     # ssh on localhost:2222
vm-stop          # ACPI shutdown, --force to kill it
vm-status        # running or not, disk size, built system
vm-reset         # delete the disk so the next boot is fresh
vm-build         # build only
```

To change the guest, edit the config here and run `vm` again, rather than rebuilding inside it: its store is the host's, with a tmpfs overlay. The guest runs at a fixed 1920x1080 that is scaled to the window. `Mod+Escape` toggles a passthrough keybind mode on the host, so binds like `Mod+T` reach the focused guest instead.

### Installer in a VM

`vm-install` (`modules/hosts/vm-install/`) is the `base` type with your terminal home-manager config (no desktop), and its disko config targets the VM's disk, `/dev/disk/by-id/virtio-install-test`. It uses LUKS and btrfs like aspire, but no TPM or Secure Boot, so `finish-install` is not needed.

```bash
vm-iso           # build .#iso and boot it (UEFI) with the install disk attached
                 # then, in the VM: sudo install-host vm-install
vm-iso-boot      # boot the installed disk without the ISO
vm-iso-ssh [cmd] # ssh into the installer as root on localhost:2223, with ~/.ssh/id_ed25519
vm-iso-stop      # ACPI shutdown, --force to kill it
vm-iso-reset     # delete the install disk and its UEFI variables
```

The ISO carries the flake as it was built, so stage new files before `vm-iso`. `vm-status` shows both VMs.

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
