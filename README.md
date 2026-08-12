# nix#aspire

NixOS configuration for niri + noctalia.

|             |                                                                                    |
| ----------- | ---------------------------------------------------------------------------------- |
| Compositor  | [niri](https://github.com/niri-wm/niri)                                            |
| Shell / bar | [noctalia](https://noctalia.dev) v5                                                |
| Terminal    | foot + zellij                                                                      |
| Editor      | Neovim via [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) |
| User env    | home-manager, as a NixOS module                                                    |
| Channel     | nixpkgs 26.05, plus nixpkgs-unstable for Neovim only                               |

`flake.nix` takes a private input, `wayland-select`, over SSH. Without access to
that repo, comment the input out and delete `programs/wayland-select.nix` before
evaluating anything.

## Usage

```bash
nrs  # rebuild + switch
nrt  # rebuild + test (no bootloader entry)
nrb  # rebuild for next boot
nrd  # dry-build
ngl  # list generations
ngc  # collect garbage older than 7d
nfu  # update flake.lock and commit it
nfmt # nixfmt the whole tree
```

These wrap `nixos-rebuild --flake ~/nix`, with no `#name`, so `nixos-rebuild`
resolves `nixosConfigurations.$(hostname)`. Keep `networking.hostName` and the
`nixosConfigurations` attribute name the same and the aliases work on every
machine.

The rest of the aliases and shell scripts are in `programs/shell/_aliases.nix`
and `programs/shell/_scripts.nix`.

First build on a fresh machine:

```bash
sudo nixos-rebuild boot --flake ~/nix#aspire --option experimental-features "nix-command flakes"
```

## Layout

Every `.nix` file in the tree is imported automatically, there are no `imports`
lists to maintain. `flake.nix` walks the repo with `lib.fileset` and picks up
everything except itself and files whose name starts with `_`. The walker only
sees files git knows about, so `git add` new files before rebuilding.

```
flake.nix        inputs, the import walker, flake-parts plumbing

hosts/           one directory per machine
  aspire/

modules/         aspects that are not a program
  base/          everything every machine gets
  desktop/       the desktop session
  gaming.nix
  virtualbox.nix

programs/        one file (or dir) per program
```

There is no split between system config and user config in the tree. An aspect
that has both a NixOS half and a home-manager half keeps them in one file, or at
least in one directory.

`_`-prefixed files are data instead of modules. `_aliases.nix`, `_binds.nix`,
`_rules.nix`, `_config.nix`, `_module.nix` are skipped by the walker and
imported explicitly by whoever needs them. If you add a file that is a plain
list or attrset rather than a module, prefix it with `_` or evaluation will
fail.

### Where does a new thing go?

- Owns more than a package (config, a service, an env var, a script, a system
  half)? `programs/[name].nix`, or `programs/[name]/` if it needs data files.
- Only a package? Append to `programs/apps.nix` (graphical) or
  `programs/cli.nix` (terminal).
- Not a program at all? `modules/base/` if every machine wants it,
  `modules/desktop/` if it belongs to the desktop session, otherwise its own
  `modules/[name].nix`.
- A namespace where you want to see every entry at once? Keep it as one
  `_`-prefixed data file.

### Modules merge by name

`flake.modules.[class].[name]` is `lazyAttrsOf (lazyAttrsOf deferredModule)`, so
many files can contribute to the same module. The option comes from
`inputs.flake-parts.flakeModules.modules`, imported in `flake.nix`.

Current modules:

```
modules.nixos         base  desktop  gaming  virtualbox  aspireHardware  hostAspire
modules.homeManager   base  desktop  dev
```

A directory name is not a promise about a module name. Directories group files
so humans can find them; the module name in each file does the actual
composition. `programs/foot.nix` writes to `desktop`, `programs/git.nix` writes
to `dev`, and `programs/bat.nix` writes to both `homeManager.dev` and
`nixos.base`.

Each entry is tagged with its module class, so writing a home-manager option
into `modules.nixos.*` (or the reverse) fails at eval with a class mismatch
rather than a confusing "option does not exist".

`nixos.base` pulls in `homeManager.base` and `homeManager.dev`; `nixos.desktop`
pulls in `homeManager.desktop`. A NixOS aspect with a home half wires it up
itself, there is no central table mapping the two.

home-manager modules get `inputs`, `username` and `monitors` as extra module
arguments, set in `modules/base/home-manager.nix`. `backupFileExtension` is
`bak`.

To add an aspect that is not a program, create `modules/[name].nix`:

```nix
{
    flake.modules.nixos.[name] = { pkgs, ... }: {
        # ...
    };
}
```

then add `self.modules.nixos.[name]` to a host's `imports`. To extend something
that already exists, write to its name from a new file.

To add a program, create `programs/[name].nix` writing to
`flake.modules.homeManager.{base,desktop,dev}`, and to `flake.modules.nixos.*`
too if it has a system half. Nothing else to wire.

## Hosts

A host is one module listing what it wants, plus its own hardware facts:

```nix
flake.nixosConfigurations.aspire = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.modules.nixos.hostAspire ];
};

flake.modules.nixos.hostAspire = {
    imports = [
        self.modules.nixos.base
        self.modules.nixos.desktop
        self.modules.nixos.gaming
        self.modules.nixos.virtualbox
        self.modules.nixos.aspireHardware
    ];

    networking.hostName = "aspire";
    # ...
};
```

`hostAspire` takes no `specialArgs`, so it can be dropped into any
`nixosSystem` call as-is.

### Adding a machine

1. On the new machine, get its hardware config:

   ```bash
   sudo nixos-generate-config --no-filesystems --show-hardware-config
   ```

2. Save it as `hosts/[host]/hardware-configuration.nix`, wrapped in
   `flake.modules.nixos.[host]Hardware`, the same shape as `aspireHardware`.

3. Write `hosts/[host]/configuration.nix` defining
   `flake.modules.nixos.host[Host]` and `flake.nixosConfigurations.[host]`, with
   the modules it wants, its `networking.hostName`, its `preferences.monitors`,
   and any vendor-specific bits (graphics drivers, bootloader).

4. `git add` the new files.

5. Rebuild:

   ```bash
   sudo nixos-rebuild boot --flake ~/nix#[host]
   ```

## Preferences

Values needed in more than one place are NixOS options under `preferences`, not
module arguments:

```
preferences.user.name          modules/base/preferences.nix
preferences.user.description   modules/base/preferences.nix
preferences.monitors           modules/base/monitors.nix
preferences.autologin          modules/desktop/autologin.nix
```

`preferences.monitors` describes displays as plain data. niri turns it into
output blocks and workspace placement, noctalia into lockscreen placement, so a
host never has to know either config format:

```nix
preferences.monitors = {
    "eDP-1" = {
        mode = "1920x1080@144";
        primary = true;
    };

    "HDMI-A-1" = {
        mode = "1920x1080@75.000";
        position.x = -1920;
    };
};
```

Per output: `mode`, `scale`, `transform`, `position.{x,y}`, `primary`. Exactly
one output should set `primary`, because named workspaces open there and the
lockscreen is drawn there. Leaving `monitors` empty lets niri autodetect, which
is what the portable `nix run .#niri` package does.

`preferences.autologin` defaults to true and boots straight into the session.
The greeter is still reachable by logging out, or by holding Space during boot
and picking the `greeter` entry, which is a specialisation with autologin
forced off. The bootloader timeout is 0, so Space is the only way into the menu.

## Backups

`modules/base/backup.nix` installs two user units that rsync a fixed list of
home directories (Desktop, Documents, Music, Pictures, Projects, Videos,
PrismLauncher) to `/mnt/storage/bak`:

- `ssd-backup.timer` runs daily, and does nothing if the SSD is not mounted.
- `ssd-restore.service` runs once on a fresh install, guarded by a stamp file at
  `~/.local/state/ssd-restore.stamp`.

Both directions are driven by the `DIRS` list at the top of
`modules/base/scripts/ssd-backup` and `ssd-restore`. `SSD_ROOT` and `BAK_ROOT`
override the paths. Aliases: `baknow`, `bakstatus`, `baklog`.

## Runnable packages

The desktop programs are exported with their config baked in, so they work on
machines that have never seen this repo:

```bash
nix run ~/nix#niri
nix run ~/nix#noctalia
nix run ~/nix#nvim
```

`perSystem` builds these against the same nixpkgs the system uses:
`modules/base/nix.nix` defines the `allowUnfree` config and the overlay list
once and feeds both `modules.nixos.base` and `perSystem._module.args.pkgs`.
`programs/neovim/` is the one exception, it imports its own `nixpkgs-unstable`
because it wants unstable specifically.

The installed Neovim reads its Lua from `~/nix/programs/neovim/config` so edits
apply without a rebuild. The `nix run` copy has that directory baked into the
store.

## Reinstalling aspire

The subvolume layout this repo expects is what the NixOS Calamares installer
produces, so the graphical path works. Pick btrfs and LUKS encryption.

Swap is force-disabled in `hostAspire` and `zramSwap` is on instead, so the
installer's swap partition is ignored. Bound the parallelism on the first big
rebuild:

```bash
sudo nixos-rebuild boot --flake ~/nix#aspire --option experimental-features "nix-command flakes" --option max-jobs 3 --option cores 4
```

The LUKS mapper name is the installer's choice. Two places name it, and both
must match the new install:

- `boot.initrd.luks.devices."<mapper>".device` in
  `hosts/aspire/hardware-configuration.nix`, along with the `fileSystems`
  entries pointing at `/dev/mapper/<mapper>`.
- `boot.initrd.luks.devices."<mapper>".allowDiscards` in
  `hosts/aspire/configuration.nix`.

Generated btrfs mounts also gain `compress=zstd,noatime`, which the current
hardware config lacks. Keep it if the installer writes it.

## Known issues

If steam misbehaves after installing it, try:

```bash
steam -cef-disable-gpu-compositing
```

If it still misbehaves, remove `~/.steam` and/or `~/.local/share/Steam/`. After
it launches, close it and launch normally so Millennium loads.

`nix flake check` warns about an unknown flake output `modules`. That is
expected, `flake.modules` is a flake-parts convention, not a nix-native output
name.
