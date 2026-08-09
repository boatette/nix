# nix#redux

NixOS configuration for niri + noctalia , built on [flake-parts](https://flake.parts), following the dendritic pattern.

|             |                                                                 |
| ----------- | --------------------------------------------------------------- |
| Compositor  | [niri](https://github.com/niri-wm/niri)                         |
| Shell / bar | [noctalia](https://noctalia.dev) v5                             |
| Terminal    | foot + zellij                                                   |
| Editor      | Neovim via [nixCats](https://github.com/BirdeeHub/nixCats-nvim) |
| User env    | home-manager, as a NixOS module                                 |

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

These wrap `nixos-rebuild --flake ~/nix#redux`.

First build on a fresh machine:

```bash
sudo nixos-rebuild boot --flake ~/nix#redux --options experimental-features "nix-command flakes"
```

## Layout

Every `.nix` file in the tree is imported automatically, there are no `imports` lists to maintain. `flake.nix` walks the repo with `lib.fileset` and picks up everything except itself and files whose name starts with `_`.

```
flake.nix        inputs + the import walker
parts.nix        flake-parts plumbing; declares flake.homeModules
theme.nix        appearance facts needed outside a NixOS eval (flake.cursor)

nixos/           system facts that are not a program
  base/          everything every machine gets
  features/      opt-in per host: desktop, fonts, gaming, virtualbox
  hosts/redux/   this machine

home/            user facts that are not a program appearance, backup

programs/        one file (or dir) per program, writing to whatever module classes that program needs
```

### Where does a new thing go?

The rule is about what a thing owns, not which module system consumes it:

- Owns more than a package (e.g. config, a service, an env var, a script, a system half)? `programs/[name].nix`, or `programs/[name]/` if it needs data files.
- Only a package? Append to `programs/apps.nix` (graphical) or `programs/cli.nix` (terminal).
- Not a program at all? `nixos/base/`.
- A namespace where you want to see every entry at once? Keep it as one `_`-prefixed data file.

`_`-prefixed files are data instead of modules. `_aliases.nix`, `_binds.nix`, `_rules.nix`, `_config.nix`, `_defs.nix` etc. are skipped by the walker and imported explicitly by whoever needs them. If you add a file that is a plain list or attrset rather than a module, prefix it with `_` or evaluation will fail.

### Modules merge by name

`flake.nixosModules.[name]` and `flake.homeModules.[name]` are `lazyAttrsOf deferredModule`, so many files can contribute to the same module. `desktop` is assembled from `nixos/features/desktop.nix`, `fonts.nix`, `programs/niri/`, `programs/noctalia/`, `programs/media.nix`, `home/appearance.nix` and more — none of them import each other.

Current modules:

```
nixosModules   base  desktop  gaming  virtualbox  reduxHardware  hostRedux
homeModules    base  desktop  dev
```

`base` pulls in `homeModules.base` and `homeModules.dev`; `nixosModules.desktop` pulls in `homeModules.desktop`. A NixOS feature with a home half wires it up itself, there is no central table mapping the two.

### Hosts

A host is one module listing what it wants, plus its own hardware facts:

```nix
flake.nixosConfigurations.redux = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.hostRedux ];
};

flake.nixosModules.hostRedux = {
    imports = [
        self.nixosModules.base
        self.nixosModules.desktop
        self.nixosModules.gaming
        self.nixosModules.virtualbox
        self.nixosModules.reduxHardware
    ];

    networking.hostName = "redux";
    # ...
};
```

`hostRedux` takes no `specialArgs`, so it can be dropped into any `nixosSystem` call as-is.

### Shared facts

Values needed in more than one place are NixOS options, not module arguments:

```nix
config.preferences.user.name # declared in nixos/base/preferences.nix
config.preferences.monitors  # declared in nixos/base/monitors.nix
self.cursor                  # published from theme.nix
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

A system feature: create `nixos/features/[name].nix`:

```nix
{
    flake.nixosModules.[name] = { pkgs, ... }: {
        # ...
    };
}
```

then add `self.nixosModules.[name]` to a host's `imports`. To extend something that already exists, just write to its name from a new file.

A program: create `programs/[name].nix` writing to `flake.homeModules.{base,desktop,dev}`, and to `flake.nixosModules.*` too if it has a system half. Nothing else to wire.

A host: create `nixos/hosts/[host]/configuration.nix` defining `flake.nixosModules.host[Host]` and `flake.nixosConfigurations.[host]`.

### Adding a machine

1. On the new machine, get its hardware config:

   ```bash
   sudo nixos-generate-config --no-filesystems --show-hardware-config
   ```

2. Save it as `nixos/hosts/[host]/hardware-configuration.nix` wrapping it in `flake.nixosModules.[host]Hardware`, the same shape as `reduxHardware`.

3. Write `nixos/hosts/[host]/configuration.nix` with the modules it wants, its `networking.hostName`, its `preferences.monitors`, and any vendor-specific bits (graphics drivers, bootloader).

4. `git add` the new files.

5. Rebuild the system safely:

   ```bash
   sudo nixos-rebuild boot --flake ~/nix#[host]
   ```

Keep `networking.hostName` and the `nixosConfigurations` attribute name the same. `nixos-rebuild` resolves `nixosConfigurations.$(hostname)` when no `#name` is given.

## Runnable packages

The desktop programs are exported with their config baked in, so they work on machines that have never seen this repo:

```bash
nix run ~/nix#niri
nix run ~/nix#noctalia
nix run ~/nix#nvim
```

## Potential issues

If steam misbehaves after installing it, try:

```bash
steam -cef-disable-gpu-compositing
```

If it still misbehaves, remove `~/.steam` and/or `~/.local/share/Steam/`. After it launches, close it and launch normally so Millennium loads.

`perSystem` `pkgs` is plain nixpkgs so it does not inherit the `allowUnfree` and overlays set in `nixos/base/nix.nix`. Anything unfree built there needs its own config; see `extra_pkg_config` in `programs/neovim/`.
