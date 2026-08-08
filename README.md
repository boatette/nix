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
theme.nix        shared appearance facts (flake.cursor)

nixos/
  base/          everything every machine gets
  features/      opt-in system features
  hosts/redux/   this machine

home/            home-manager modules
wrappedPrograms/ programs configured in Nix, also exported as packages
dotfiles/        plain config files, symlinked into $HOME
```

`_`-prefixed files are data instead of modules. `_aliases.nix`, `_binds.nix`, `_rules.nix`, `_config.nix`, `_defs.nix` etc. are skipped by the walker and imported explicitly by whoever needs them. If you add a file that is a plain list or attrset rather than a module, prefix it with `_` or evaluation will fail.

### Modules merge by name

`flake.nixosModules.[name]` and `flake.homeModules.[name]` are `lazyAttrsOf deferredModule`, so many files can contribute to the same module. `desktop` is assembled from `nixos/features/desktop.nix`, `fonts.nix`, `wrappedPrograms/niri/`, `wrappedPrograms/noctalia/`, `home/theme.nix` and more — none of them import each other.

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
self.cursor                  # published from theme.nix
```

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

A home-manager feature: create `home/[name].nix` writing to `flake.homeModules.{base,desktop,dev}`. Nothing else to wire.

A host: create `nixos/hosts/[host]/configuration.nix` defining `flake.nixosModules.host[Host]` and `flake.nixosConfigurations.[host]`.

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

`perSystem` `pkgs` is plain nixpkgs so it does not inherit the `allowUnfree` and overlays set in `nixos/base/nix.nix`. Anything unfree built there needs its own config; see `extra_pkg_config` in `wrappedPrograms/neovim/`.
