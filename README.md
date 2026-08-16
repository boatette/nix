# nix#aspire

NixOS configuration for niri + noctalia.

|             |                                                      |
| ----------- | ---------------------------------------------------- |
| Compositor  | [niri](https://github.com/niri-wm/niri)              |
| Shell / bar | [noctalia](https://noctalia.dev) v5                  |
| Terminal    | foot + zellij                                        |
| Editor      | Neovim                                               |
| User env    | home-manager                                         |
| Channel     | nixpkgs 26.05, plus nixpkgs-unstable for Neovim only |

## Layout

Every `.nix` file under `modules/` is a flake-parts module, imported automatically by [import-tree](https://github.com/denful/import-tree). `flake.nix` is just inputs and one line. The walker only sees files git knows about, so `git add` new files before rebuilding.

```
~/nix/
├── flake.nix                  inputs, and one line handing ./modules to import-tree
└── modules/
    ├── nix/                   how the flake itself is assembled
    │   └── packages.nix         collects every *.pkg.nix in the tree
    ├── hosts/                 one directory per machine
    │   └── aspire/              disko, hardware, graphics, monitors, storage
    ├── system/                aspects that are not a program
    │   ├── base/                everything every machine gets
    │   ├── desktop/             the desktop session
    │   ├── backup/              a module that ships scripts with it
    │   ├── preferences.nix      the options a host sets
    │   └── gaming.nix           an aspect a host opts into
    └── programs/              one file, or one directory, per program
        ├── cli.nix              a bare package list, terminal
        ├── apps.nix             a bare package list, graphical
        ├── zellij.nix           a program that owns only settings
        ├── shell/               fish, its aliases, and the scripts it carries
        ├── foot/                a program that owns data and scripts too
        │   ├── foot.nix           the module
        │   ├── _settings.nix      data, shared with the package below
        │   └── foot-themed.pkg.nix
        ├── noctalia/            big enough to split its settings up
        │   └── _settings/         a whole directory skipped by the walker
        └── nvim/
            └── config/            plain lua, edited live, no rebuild
```

Three file-naming conventions, and that is the whole vocabulary:

| Name           | Meaning                                                                                                                                        |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `_name.nix`    | Data imported explicitly by whoever needs it. Skipped by the walker, which ignores any path containing `/_`                                    |
| `name.pkg.nix` | A package, Picked up by `modules/nix/packages.nix`, which publishes it as `pkgs.name` for every module _and_ as a flake package `nix run`-able |
| `name.nix`     | A module, merged into `flake.modules.<class>.<aspect>`.                                                                                        |

Aspects are just names that many files write to: import `nixos.desktop` and you get every file that contributes to it. A `homeManager` aspect is attached to the `nixos` aspect of the same name automatically, so there is no bridge to write. Values are shared through options (`config.preferences.*`, or `osConfig.preferences.*` from a home-manager module), never `specialArgs`.

### Where does a new thing go?

- Owns more than a package (config, a service, an env var, a script, a system half)? `modules/programs/[name].nix`, or `modules/programs/[name]/` if it needs data or scripts.
- Only a package? Append to `modules/programs/apps.nix` (graphical) or `cli.nix` (terminal).
- Not a program at all? `modules/system/base/` if every machine wants it, `modules/system/desktop/` if it belongs to the desktop session, otherwise its own `modules/system/[name].nix`.
- A new machine? `modules/hosts/[name]/`, with a `flake-parts.nix` calling `mkNixos "<system>" "[name]"`. Everything else in that directory merges into `flake.modules.nixos.[name]`.
- A namespace where you want to see every entry at once? Keep it as one `_`-prefixed data file.

## Running it anywhere

Any machine with nix and an internet connection can run a piece of this config without installing it:

```bash
nix run github:boatette/nix#shell-env    # fish, with every alias, function and tool
nix run github:boatette/nix#nvim
nix run github:boatette/nix#niri
nix run github:boatette/nix#noctalia
nix run github:boatette/nix#extract -- archive.tar.zst
```

`nix flake check` builds every one of them, which is what keeps that promise honest — a package that reaches for `/home/boatette` or a local-path input stops building here before it stops working elsewhere.

`nix fmt` formats the tree (nixfmt for nix, stylua for the Neovim config). Shell scripts are deliberately excluded; they are checked by shellcheck at build time instead, via `writeShellApplication`.

## Installing

Partitioning is declarative, in `modules/hosts/aspire/disko.nix`. Use the minimal ISO, no graphical installer is involved. `fileSystems` is generated by disko, so nothing under `modules/hosts/` needs editing per install.

1. Setup the ISO environment:

   ```bash
   sudo -i
   nmtui
   ```

2. Enable flakes for the rest of the session:

   ```bash
   export NIX_CONFIG="experimental-features = nix-command flakes"
   ```

3. Partition, format and mount. Print the script and read it first:

   ```bash
   nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:boatette/nix#aspire --dry-run
   ```

   Drop `--dry-run` to do it.

4. Clone the repo to where it lives after the reboot:

   ```bash
   mkdir -p /mnt/home/boatette
   nix run nixpkgs#git -- clone https://github.com/boatette/nix.git /mnt/home/boatette/nix
   ```

5. Install:

   ```bash
   nixos-install --flake /mnt/home/boatette/nix#aspire --option max-jobs 3 --option cores 4 --option extra-substituters "https://nix-community.cachix.org https://noctalia.cachix.org" --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
   ```

   Job bounds and cachix help with ram usage and aren't technically required.

> [!TIP]
>
> ```bash
> cat /mnt/home/boatette/nix/README.md | grep -m 1 nixos-install > sh
> ```
>
> To run it without manually typing cachix keys

6. Set the user password before rebooting:

   ```bash
   nixos-enter --root /mnt -c 'passwd boatette'
   chown -R 1000:100 /mnt/home/boatette
   ```

7. Reboot
