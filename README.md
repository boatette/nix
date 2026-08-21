# NixOS Config

NixOS configuration for niri + noctalia.

|             |                                         |
| ----------- | --------------------------------------- |
| Compositor  | [niri](https://github.com/niri-wm/niri) |
| Shell / bar | [noctalia](https://noctalia.dev) v5     |
| Terminal    | foot + zellij                           |
| Editor      | Neovim, via nixvim                      |
| Shell       | fish                                    |
| User env    | home-manager                            |
| Channel     | nixpkgs unstable                        |

## Layout

Every `.nix` file under `modules/` is a flake-parts module, imported automatically by [import-tree](https://github.com/denful/import-tree). `flake.nix` is generated from the inputs each feature declares, by `nix run .#write-flake`. The walker only sees files git knows about, so `git add` new files before rebuilding.

```
~/nix/
├── flake.nix                  generated; inputs, and one line handing ./modules to import-tree
├── packages/                  one directory per package, collected by pkgs-by-name
└── modules/
    ├── nix/                   how the flake itself is assembled
    │   ├── flake-parts/         the dendritic setup, mkNixos, formatter, checks
    │   └── pkgs-by-name/        publishes packages/ as pkgs.local.* and as nix run targets
    ├── hosts/                 one directory per machine
    │   └── aspire/              disko, hardware, graphics, monitors, storage
    ├── system/                aspects that are not a program
    │   ├── settings/            everything every machine gets
    │   ├── session/             the graphical session
    │   ├── constants/           the values every class can read
    │   └── types/               base.nix and desktop.nix, the two rungs
    ├── services/              aspects that own units and timers
    │   └── backup/              a feature whose scripts live in packages/
    ├── programs/              one file, or one directory, per program
    │   ├── cli-tools.nix        a bare package list, terminal
    │   ├── apps.nix             a bare package list, graphical
    │   ├── zellij.nix           a program that owns only settings
    │   ├── shell/               fish, its aliases, and its functions
    │   ├── foot/                a program that owns a theme template too
    │   ├── noctalia/            big enough to split its settings up
    │   ├── niri/                its own module class, one file per section
    │   └── nvim/                its own module class, one file per concern
    └── users/                 one directory per user
        └── boatette/
```

Two naming conventions, and that is the whole vocabulary:

| Name             | Meaning                                                                                            |
| ---------------- | -------------------------------------------------------------------------------------------------- |
| `name.nix`       | A module, merged into `flake.modules.<class>.<aspect>`.                                            |
| `packages/name/` | A package. Published as `pkgs.local.name` for every module _and_ as a flake package `nix run`-able |

Aspects are just names that many files write to: import `nixos.desktop` and you get every file that contributes to it. A `homeManager` aspect reaches the system either because a rung imports it or because a feature carries it in with `home-manager.sharedModules` — one path only, never both, or the module system sees it twice. Values are shared through options (`config.constants.*`, or `inputs.self.constants` from a class that has no `config`), never `specialArgs`.

Five classes, and two of them are the interesting ones:

| Class                  | What it configures                                                        |
| ---------------------- | ------------------------------------------------------------------------- |
| `nixos`, `homeManager` | the system and the user                                                   |
| `generic`              | no class of its own; readable from either                                 |
| `nixvim`, `niri`       | the editor and the compositor, each assembled into a package and a module |

`nixvim` and `niri` work the same way: every file in the directory writes to `flake.modules.<class>.<name>`, and one wiring file turns the merged result into both `nix run .#name` and the half home-manager installs. Because they merge, a program can carry its own corner of them — `zen/zen.nix` holds the niri window rule for zen, and `nvim/theme.nix` holds the noctalia template that themes Neovim, next to the config that reads it. The same is true of MIME: no central table, each app declares what it opens.

### Where does a new thing go?

- Owns more than a package (config, a service, an env var, a theme template, a system half)? `modules/programs/[name].nix`, or `modules/programs/[name]/` if it needs data too.
- Only a package? Append to `modules/programs/apps.nix` (graphical) or `cli-tools.nix` (terminal).
- A shell one-liner? `modules/programs/shell/functions.nix`, as a fish function. Only reach for `packages/` when it needs real dependencies, or has to exist as a binary something else can call.
- Not a program at all? `modules/system/settings/` if every machine wants it, `modules/system/session/` if it belongs to the desktop session, otherwise its own directory.
- Something it should be the default handler for, a window rule, a colour template? Put it in that program's own directory. Nothing central needs editing.
- A new machine? `modules/hosts/[name]/`, with a `flake-parts.nix` calling `mkNixos "<system>" "[name]"`. Everything else in that directory merges into `flake.modules.nixos.[name]`.
- A new input? Declare it beside the feature that needs it, then `nix run .#write-flake`.

## Running it anywhere

Any machine with nix and an internet connection can run a piece of this config without installing it:

```bash
nix run github:boatette/nix#nvim
nix run github:boatette/nix#niri
nix run github:boatette/nix#walls-pull
nix run github:boatette/nix#prune-small -- --min 2560x1440
```

`nix flake check` builds every one of them, which is what keeps that promise honest — a package that reaches for `/home/boatette` or a local-path input stops building here before it stops working elsewhere. It also fails if `flake.nix` is stale, and niri validates its own config at build time, so a bad bind breaks the build rather than the session.

`nix fmt` formats the tree (nixfmt for nix, stylua for lua). Shell scripts are deliberately excluded; they are checked by shellcheck at build time instead, via `writeShellApplication`, and the python the same way with flake8.

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
