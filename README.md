# nix#aspire

NixOS configuration for niri + noctalia.

|             |                                                                                    |
| ----------- | ---------------------------------------------------------------------------------- |
| Compositor  | [niri](https://github.com/niri-wm/niri)                                            |
| Shell / bar | [noctalia](https://noctalia.dev) v5                                                |
| Terminal    | foot + zellij                                                                      |
| Editor      | Neovim via [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) |
| User env    | home-manager, as a NixOS module                                                    |

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

These wrap `nixos-rebuild --flake ~/nix`, with no `#name`, so `nixos-rebuild` resolves `nixosConfigurations.$(hostname)`. Keep `networking.hostName` and the `nixosConfigurations` attribute name the same and the aliases work on every machine.

First build on a fresh machine:

```bash
sudo nixos-rebuild boot --flake ~/nix#aspire --option experimental-features "nix-command flakes"
```

## Layout

Every `.nix` file in the tree is imported automatically, there are no `imports` lists to maintain. `flake.nix` walks the repo with `lib.fileset` and picks up everything except itself and files whose name starts with `_`.

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

There is no split between system config and user config in the tree. An aspect that has both a NixOS half and a home-manager half keeps them in one file, or at least in one directory: `modules/desktop/` holds the greeter and the polkit rule next to the GTK theme and the cursor.

### Where does a new thing go?

The rule is about what a thing owns, not which module system consumes it:

- Owns more than a package (e.g. config, a service, an env var, a script, a system half)? `programs/[name].nix`, or `programs/[name]/` if it needs data files.
- Only a package? Append to `programs/apps.nix` (graphical) or `programs/cli.nix` (terminal).
- Not a program at all? `modules/base/` if every machine wants it, `modules/desktop/` if it belongs to the desktop session, otherwise its own `modules/[name].nix`.
- A namespace where you want to see every entry at once? Keep it as one `_`-prefixed data file.

`_`-prefixed files are data instead of modules. `_aliases.nix`, `_binds.nix`, `_rules.nix`, `_config.nix`, `_module.nix` etc. are skipped by the walker and imported explicitly by whoever needs them. If you add a file that is a plain list or attrset rather than a module, prefix it with `_` or evaluation will fail.

### Modules merge by name

`flake.modules.[class].[name]` is `lazyAttrsOf (lazyAttrsOf deferredModule)`, so many files can contribute to the same module. The option comes from `inputs.flake-parts.flakeModules.modules`, imported in `flake.nix`.

Current modules:

```
modules.nixos         base  desktop  gaming  virtualbox  aspireHardware  hostAspire
modules.homeManager   base  desktop  dev
```

`desktop` is assembled from `modules/desktop/`, `programs/niri/`, `programs/noctalia/`, `programs/media.nix`, `programs/foot.nix` and more — none of them import each other.

**A directory name is not a promise about a module name.** Directories group files so humans can find them; the module name in each file does the actual composition. `programs/foot.nix` writes to `desktop`, `programs/git.nix` writes to `dev`, and `programs/bat.nix` writes to both `homeManager.dev` and `nixos.base`.

Each entry is tagged with its module class, so writing a home-manager option into `modules.nixos.*` (or the reverse) fails at eval with a class mismatch rather than a confusing "option does not exist".

`nixos.base` pulls in `homeManager.base` and `homeManager.dev`; `nixos.desktop` pulls in `homeManager.desktop`. A NixOS aspect with a home half wires it up itself, there is no central table mapping the two.

### Hosts

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

`hostAspire` takes no `specialArgs`, so it can be dropped into any `nixosSystem` call as-is.

### Shared facts

Values needed in more than one place are NixOS options, not module arguments:

```nix
config.preferences.user.name # declared in modules/base/preferences.nix
config.preferences.monitors  # declared in modules/base/monitors.nix
```

`preferences.monitors` describes displays as plain data. niri turns it into output blocks and workspace placement, noctalia into lockscreen placement, so a host never has to know either config format:

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

Exactly one output should set `primary` because named workspaces open there and the lockscreen is drawn there. Leaving `monitors` empty lets niri autodetect, which is what the portable `nix run .#niri` package does.

## Adding things

An aspect that is not a program: create `modules/[name].nix`:

```nix
{
    flake.modules.nixos.[name] = { pkgs, ... }: {
        # ...
    };
}
```

then add `self.modules.nixos.[name]` to a host's `imports`. To extend something that already exists, just write to its name from a new file.

A program: create `programs/[name].nix` writing to `flake.modules.homeManager.{base,desktop,dev}`, and to `flake.modules.nixos.*` too if it has a system half. Nothing else to wire.

### Adding a machine

1. On the new machine, get its hardware config:

   ```bash
   sudo nixos-generate-config --no-filesystems --show-hardware-config
   ```

2. Save it as `hosts/[host]/hardware-configuration.nix` wrapping it in `flake.modules.nixos.[host]Hardware`, the same shape as `aspireHardware`.

3. Write `hosts/[host]/configuration.nix` defining `flake.modules.nixos.host[Host]` and `flake.nixosConfigurations.[host]`, with the modules it wants, its `networking.hostName`, its `preferences.monitors`, and any vendor-specific bits (graphics drivers, bootloader).

4. `git add` the new files. The walker only sees files git knows about.

5. Rebuild the system safely:

   ```bash
   sudo nixos-rebuild boot --flake ~/nix#[host]
   ```

## Runnable packages

The desktop programs are exported with their config baked in, so they work on machines that have never seen this repo:

```bash
nix run ~/nix#niri
nix run ~/nix#noctalia
nix run ~/nix#nvim
```

`perSystem` builds these against the same nixpkgs the system uses — `modules/base/nix.nix` defines the `allowUnfree` config and the overlay list once and feeds both `modules.nixos.base` and `perSystem._module.args.pkgs`. `programs/neovim/` is the one exception: it imports its own `nixpkgs-unstable` because it wants unstable specifically.

## Potential issues

If steam misbehaves after installing it, try:

```bash
steam -cef-disable-gpu-compositing
```

If it still misbehaves, remove `~/.steam` and/or `~/.local/share/Steam/`. After it launches, close it and launch normally so Millennium loads.

`nix flake check` warns about an unknown flake output `modules`. That is expected: `flake.modules` is a flake-parts convention, not a nix-native output name.
