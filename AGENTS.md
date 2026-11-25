# Agent guide

How this flake works and how changes to it are expected to look. The README covers installing, Secure Boot and impermanence from a person's side; this file is for editing the config.

## What this is

A NixOS + home-manager flake for one user (`boatette`) on one machine, `aspire`: a laptop with Intel + NVIDIA under PRIME offload, LUKS + TPM, lanzaboote Secure Boot, and a root that is wiped on every boot. It is installed offline from its own ISO (`nix build .#iso`), which carries the system prebuilt, or from the official NixOS ISO with `nix run github:boatette/nix#install`.

The desktop is [umbriel](https://github.com/noctalia-dev/umbriel), a scrolling Wayland compositor, with [noctalia](https://github.com/noctalia-dev/noctalia-shell) as its shell, bar, lockscreen, launcher and greeter. Everything is themed **Rosé Pine main**.

## How the flake is assembled

Every file is a flake-parts module, imported automatically by `import-tree`, and every file adds straight to one of three modules:

| Module                               | Holds                                                     |
| ------------------------------------ | --------------------------------------------------------- |
| `flake.modules.nixos.aspire`         | the system; `nixosConfigurations.aspire` is built from it |
| `flake.modules.homeManager.boatette` | the user's home-manager config                            |
| `flake.modules.nvf.nvim`             | the neovim build (see [Neovim](#neovim))                  |

- There are no import lists and no feature names: a file that exists is on. To switch one off, rename it with a leading `_` (`import-tree` skips any path containing `/_`).
- Any number of files contribute to the same module and their definitions merge. A program that needs both system and user config defines both in its file (`rmpc.nix`, `btop.nix`, `zsh.nix`).
- Nix only sees files git tracks, so a new file needs `git add` (or `git add -N`) before it exists to the flake.
- **`flake.nix` is generated** by flake-file. Never edit it. An input is declared next to the module that uses it, with `flake-file.inputs.<name> = { ... };`, and `nix run .#write-flake` regenerates `flake.nix` from them all.
- The host is built in `modules/hosts/aspire/configuration.nix`. `modules/users/boatette.nix` declares the account and hands `homeManager.boatette` to home-manager through `home-manager.sharedModules`, so nixd's home-manager completion sees every option.
- The system and home-manager (`useGlobalPkgs`) share one `pkgs` from `modules/nix/nixpkgs.nix`, with unfree allowed and the local overlay applied.
- **Local packages** live in `packages/<name>/package.nix`, picked up by `lib.filesystem.packagesFromDirectoryRecursive` in `modules/nix/packages.nix`: no registration needed, and `callPackage` can also take `inputs`. Each is a flake output (`nix build .#<name>`) and is used in modules as `pkgs.local.<name>`. Shell tools are `writeShellApplication` with the script in `packages/<name>/<name>.sh`, read in with `builtins.readFile`, so shellcheck runs at build time.

## Layout

```
modules/
├── nix/                 how the flake is assembled: inputs, pkgs, packages, home-manager, rebuild commands
│   └── flake-parts/     flake.lib core helpers, checks, formatter, devshell, systems
├── hosts/
│   ├── aspire/          the machine: configuration, hardware, graphics, disko, monitors, storage
│   └── iso/             the offline installer, with aspire's toplevel and disko script baked in
├── system/
│   ├── constants.nix    shared values (see below)
│   ├── settings/        boot, locale, nix settings, install plan, packages, ...
│   ├── session/         the graphical session: greeter, fonts, audio, console, ...
│   ├── appearance/      GTK, Qt/Kvantum and the colour helpers
│   └── mime/            the mimeHandlers helper
├── services/            systemd services
├── programs/            one file per program, plus a directory for its facets
└── users/               the user account
packages/                local packages, as pkgs.local.<name>
assets/                  the wallpaper
```

## Constants

`modules/system/constants.nix` defines `flake.constants`, the values more than one module needs. Never hardcode any of these. Every module reads them as **`inputs.self.constants.<key>`**, usually through `inherit (inputs.self.constants) <key>;`.

| Key                                             | Holds                                                                                                            |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `username`, `description`, `email`              | the user account and git identity                                                                                |
| `flakeDir`, `repo`                              | where the flake is checked out (`~/nix`), and its GitHub repo                                                    |
| `release`                                       | the NixOS release tracked: `"unstable"`, or `"26.11"` once that is out                                           |
| `nixpkgsBranch`, `homeManagerBranch`            | the branches `release` means, used by the inputs, qutebrowser's nix searches and noctalia's nix-monitor          |
| `locale`, `locales`, `timeZone`, `stateVersion` | system basics; `locales` are the ones glibc builds, for the system and every FHS env                             |
| `keyboard.{layout,options}`                     | XKB, shared by the session and the greeter                                                                       |
| `fonts.{mono,sans}.{name,size}`                 | JetBrainsMono Nerd Font and Inter                                                                                |
| `cursor.{name,size}`                            | the Rosé Pine cursor                                                                                             |
| `glass.{radius,opacity}`                        | the corner radius and translucency of everything (12 and 0.8)                                                    |
| `monitors`                                      | the two outputs, their modes and the arm's layouts (see [Monitors](#monitors))                                   |
| `palette.<name>`                                | Rosé Pine main as `rrggbb` without `#`, the twelve colours plus `highlightLow`, `highlightMed`, `highlightHigh`  |
| `roles.<role>`                                  | the palette name each role uses: `primary` rose, `secondary` foam, `tertiary` pine, `warning` gold, `error` love |

Rules:

- `glass` is the only place to change roundness or translucency. The bar, umbriel's windows and borders, foot, luciole, selector and noctalia's widgets all read it. 12 and 0.8 aren't arbitrary: they are what noctalia hardcodes for the parts it doesn't expose.
- `roles` mirror noctalia's builtin Rosé Pine scheme, so hand-coloured programs agree with the shell. Colour by role where there is one, and by palette name otherwise.
- Moving to a new NixOS release is `release = "26.11";`, then `nfu`.
- A new value that several modules need, and that isn't already an option they can read, belongs in constants.

## Monitors

There are only ever two outputs: `eDP-1`, always there, and `HDMI-A-1`, on a swivel arm and plugged in about half the time. They are plain data in `constants.monitors` (`modules/hosts/aspire/monitors.nix`):

- `primary` (`eDP-1`) gets games, the greeter, the lockscreen login box and clock; `arm` is `HDMI-A-1`.
- `modes.<connector>` is each output's mode string.
- `layouts.{landscape,portrait}` are the arm's two positions as wlr-randr reports them, with nothing at negative coordinates, where XWayland misplaces clients. umbriel starts in `landscape` (`modules/programs/umbriel/output.nix`), and monitor-autorotate switches between them, writing each through `inputs.self.lib.umbrielLayout pkgs name layout`.

Read by `modules/programs/umbriel/output.nix`, `modules/programs/noctalia/{bar,lockscreen-widgets}.nix`, `modules/system/session/greeter.nix`, `modules/programs/gaming/steam.nix` (gamescope's resolution and refresh) and `modules/services/monitor-autorotate.nix`.

## Other helpers

`flake.lib` holds shared functions, used as `inputs.self.lib.<name>`. Put a new helper in the file for its domain rather than repeating code across modules.

| Helper                                                       | Defined in                              | Does                                                                           |
| ------------------------------------------------------------ | --------------------------------------- | ------------------------------------------------------------------------------ |
| `colours.hex name`                                           | `modules/system/appearance/colours.nix` | `"#rrggbb"` of a palette or role name                                          |
| `colours.alpha name opacity`                                 | same                                    | `"#rrggbbaa"`                                                                  |
| `colours.mix a b t`                                          | same                                    | `a` laid over `b` at opacity `t`, as noctalia blends its containers            |
| `colours.rgb name`, `colours.alphaHex opacity`               | same                                    | `"r, g, b"`, and an opacity as two hex digits                                  |
| `umbrielLayout pkgs name layout`                             | `modules/programs/umbriel/output.nix`   | a layout as an umbriel config file, with a vertical strip on a portrait output |
| `rebuild.{os,osDev,dryBuild,update,upgrade,clean,cleanArgs}` | `modules/nix/rebuild.nix`               | the rebuild, update and clean commands that aliases, noctalia and nvim run     |
| `mimeHandlers { "<app>.desktop" = [ types ]; }`              | `modules/system/mime/handlers.nix`      | default and added mime associations                                            |
| `qtFont font`                                                | `modules/nix/flake-parts/lib.nix`       | a Qt font string from a `constants.fonts` entry                                |
| `nvidiaOffloadEnv`                                           | same                                    | the PRIME offload environment variables                                        |
| `nvidiaOffloadWrap pkgs pkg bin`                             | same                                    | wraps `bin` to run on the dGPU                                                 |
| `glibcAssertion pkgs input`                                  | same                                    | an assertion that an input's own nixpkgs has at least the system's glibc       |
| `nvim.{cmd,lua,mod}`                                         | `modules/programs/nvim/lib.nix`         | nvf keymap constructors                                                        |

## Conventions

### Files

- **One concern per file, named after what it configures.** A program is `modules/programs/<name>.nix`. Its facets go in `modules/programs/<name>/`:
  - `theme.nix`: its Rosé Pine port
  - `mime.nix`: its file associations, through `mimeHandlers`
  - `umbriel.nix`: its window and layer rules

  So an app's window rules live with the app, not in `modules/programs/umbriel/`. That directory only holds the compositor's own settings and the general rules.

- **noctalia is one file per TOML section** in `modules/programs/noctalia/`, named after it: `dock.nix` sets `programs.noctalia.settings.dock`, and `plugin-settings.nix` sets `plugin_settings`. umbriel's settings follow the same pattern in `modules/programs/umbriel/`; `modules/programs/umbriel.nix` declares the small `programs.umbriel.settings` option that writes its `config.toml`.
- **Set only what differs from the default.** A value equal to upstream's, or one another module already sets, gets removed.

### Theming

- Rosé Pine **main** only. Not moon, not dawn, and no stylix.
- Native ports come first: a theme nixpkgs already ships (foot's), the official `rose-pine/*` repos, or ports listed on rosepinetheme.com. A port is a non-flake input named `rose-pine-<app>`, declared in that app's `theme.nix` (or its main file).
- A port that only restates the palette's hexes is replaced by the palette (starship, fzf).
- Colour by hand only when no port exists, through `inputs.self.lib.colours` and the roles: umbriel, selector, searxng, the console. Never write a hex value or a blend by hand.
- noctalia uses its builtin `Rosé Pine` scheme, and its community templates are off.
- luciole has no port. noctalia renders its palette into luciole's `colors.toml` through a user template (`modules/programs/luciole/theme.nix`), so leave it uncoloured by hand.

### Flake inputs

- Prefer nixpkgs. An input stays only when nixpkgs lacks it or lags in a way that matters (claude-code and grok want the newest release).
- Every flake input sets `inputs.nixpkgs.follows = "nixpkgs"`. Compositor, shell and greeter inputs that brought their own nixpkgs once had a different glibc from the system Mesa, and the greeter boot-looped (2026-10-06).
- The one exception is luciole, which tracks its `cachix` branch without `follows` so noctalia.cachix.org has it prebuilt. Its module asserts `glibcAssertion`, so a cachix branch on an older glibc fails evaluation rather than the boot.
- Dev-only inputs of inputs are emptied with `follows = ""`, and duplicates follow ours (flake-parts).
- A repo that isn't a flake (themes) gets `flake = false`.
- The user's own projects are `github:boatette/<name>` (monitor-autorotate, selector, toothless). `nrsd`/`nrbd` build them from their working trees in `~/Projects`.
- After adding, removing or changing an input, run `nix run .#write-flake`. The `check-flake-file` check fails while `flake.nix` differs from what it would generate.

### Nix style

- Formatted by nixfmt (`nix fmt`).
- A module function destructures only the arguments it uses, in alphabetical order: `{ config, lib, pkgs, ... }`. deadnix fails the check on unused ones. A module that needs no arguments is a plain attrset.
- Prefer `inherit (inputs.self.constants) fonts;` or `inherit (x) a b;` over repeated paths, and a `let` block for values used more than once.
- Use `lib.getExe pkgs.foo` / `lib.getExe' pkgs.foo "bin"` rather than store paths written out by hand.
- Package lists use `with pkgs; [ ... ]`, plus `++ [ ... ]` for anything not from `pkgs`.
- **Sorting:** lists whose order means nothing (packages, mime types, grammars, extraPackages, kernel modules) are alphabetical. Lists whose order matters keep it: window and layer rules, bar widgets, dock pins, idle steps, session actions. In an attrset, `enable` and `package` come first, then groups separated by blank lines, alphabetical inside a group unless there is a natural order (hjkl, 1 to 9, left to right).
- Generate repetition (`lib.genAttrs`, `lib.concatMapAttrs`) rather than writing out near-identical entries.
- Separate logical groups with a blank line.
- Put a `/* lua */` annotation before a multi-line Lua string so editors highlight it.
- Use `lib.mkBefore`/`lib.mkAfter` when list order matters. umbriel applies window rules in order, and the general ones in `modules/programs/umbriel/window-rule.nix` are `mkBefore`.

### Comments

- Few of them, one line each, lowercase, no trailing full stop.
- Explain **why**: an upstream quirk, where a number came from, what breaks without the line. Never restate what the code says; restructure code that needs explaining instead.
- The only markers are `# TODO:` and `# FIX:`. Commented-out config is allowed only on the lines directly under one, for what the marker brings back (see `modules/programs/gaming/steam.nix`).

### Spelling

Australian/British English in file names, names and prose (`colourscheme.nix`, "visualiser"). Upstream option and key names keep their own spelling (`colors.nix` sets umbriel's `colors`).

### Other languages

- Lua (nvim runtime): stylua, 4 spaces, 120 columns, double quotes, parentheses on every call (`.stylua.toml`).
- Everything else follows `.editorconfig`: 2 spaces, LF, a final newline.
- treefmt also formats Markdown, JSON and YAML (prettier), shell (shfmt), Python (ruff) and TOML (taplo).

### Neovim

neovim is one nvf build, `packages.nvim`, from `flake.modules.nvf.nvim` in `modules/programs/nvim/`. It is installed system-wide with `EDITOR=nvim`, and provides `vi` and `vim` too.

- `modules/programs/nvim/runtime/` (Lua under `lua/config/`, snippets under `snippets/`) is on the runtime path.
- Each keymap lives in the file of the plugin it needs and is built with `inputs.self.lib.nvim.{cmd,lua,mod}`.
- Pickers, LSP navigation, diagnostics lists and undo history are all snacks.
- Only the tools for editing this config are bundled: nixd, lua-language-server, bash and JSON servers, nixfmt, stylua, shfmt, prettierd, taplo, statix, deadnix and markdownlint. Toolchain servers, formatters, linters and debug adapters (clangd, gopls, pyright, ruff, rust-analyzer, zls, lldb-dap, debugpy, ...) come from each project's devshell through direnv: nvim starts them by name and skips any that isn't on `PATH`. A new project's flake puts them in its `devShells.default`.
- `jk` and `kj` leave insert mode, through better-escape.nvim.

## Git

The git settings below come from `modules/programs/git.nix` and `modules/programs/git/signing.nix`.

### Commit messages

- [Conventional Commits](https://www.conventionalcommits.org), as a single subject line: `type(scope): summary`. No body.
- The summary is lowercase, has no trailing full stop and stays under about 70 characters. It says what changed in plain words and doesn't have to be imperative:
  - `fix(ssd): refuse to back up over a backup that was never restored`
  - `refactor(nvim): put each keymap with what it needs`
  - `feat(apps): bambu-studio from the official AppImage`
- Types:

  | Type       | For                                                                                         |
  | ---------- | ------------------------------------------------------------------------------------------- |
  | `feat`     | something new: a program, service, widget, keybind or setting                               |
  | `fix`      | something broken that works again                                                           |
  | `refactor` | changing or removing existing config: tweaks, cleanups, dropping a program or stale setting |
  | `perf`     | faster builds or startup, smaller closures                                                  |
  | `style`    | formatting only, with no change to the output                                               |
  | `docs`     | the README and this file                                                                    |
  | `revert`   | bringing back something that was removed (`revert: re-add claude-code`)                     |

- The scope is the program or module, lowercase and spelled as its file or directory is named: `noctalia`, `umbriel`, `nvim`, `qutebrowser`, `monitor-autorotate`. Several scopes are separated by `, ` (`refactor(apps, cli-tools): ...`). Leave the scope out for a change across the whole repo (`refactor: consistency pass`).

### What goes in a commit

- One logical change per commit. A cleanup that touches many programs is a series of scoped commits, not one big one.
- Updating existing inputs is a commit of its own, made by `nix flake update --commit-lock-file` (`nfu`, or `nix flake update <input> --commit-lock-file` for one input). Its message is nix's `flake.lock: Update` with the generated body. Never write one by hand.
- Adding, removing or repointing an input is different. The module that declares it, `flake.nix` regenerated by `write-flake`, and the `flake.lock` change nix writes on the next evaluation all go in one commit.
- `/result` and `.direnv/` are ignored. Never commit build output.
- Commits and tags are SSH-signed automatically (`commit.gpgsign`, `tag.gpgsign`). Don't pass `--no-gpg-sign`. The `allowedSigners` key in `signing.nix` isn't the local `~/.ssh/id_ed25519` that signs, which is why `git log --show-signature` reports unknown validity. Leave that alone unless asked, and never reuse that key for SSH access.

### Branches and history

- `master` is the only long-lived branch. It is pushed to `origin` (`git@github.com:boatette/nix.git`, public).
- Small changes are committed straight to `master`.
- A larger effort gets its own branch, named after the topic in plain lowercase with no prefix: `sweep`, `stable`, `monitor-autorotate`. It is merged back with `git merge --no-ff <branch>`, keeping git's default `Merge branch '<branch>'` message, and then deleted.
- Otherwise history stays linear. `pull.rebase` is on, with `rebase.autoStash` and `rebase.updateRefs`, so `git pull` rebases local commits. `rerere` is on, and conflicts are shown in `zdiff3` style.
- `push.autoSetupRemote` and `push.followTags` are on, so a new branch's first push sets its upstream, and tags travel with the commits.

### What an agent may do

- Commit, branch, merge or push only when asked.
- Never amend, rebase or force-push commits that are already on `origin`.
- Nix only sees files git tracks, so `git add` (or `git add -N`) a new file before building, even if it won't be committed yet.

## Checking a change

| Command                                                                      | What it does                                                                                      |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `nix fmt`                                                                    | formats the tree with treefmt                                                                     |
| `nix flake check`                                                            | builds every package and the system, and runs deadnix, statix and the formatting check            |
| `nix build .#checks.x86_64-linux.<name>`                                     | one check: `statix`, `deadnix`, `formatting`, `check-flake-file`, `package-<name>`, `host-aspire` |
| `nix eval .#nixosConfigurations.aspire.config.system.build.toplevel.drvPath` | evaluates aspire without building it                                                              |
| `nix build .#nixosConfigurations.aspire.config.system.build.toplevel`        | builds aspire without activating it                                                               |
| `nix run .#install -- --dry-run`                                             | the install plan and disko's script, changing nothing                                             |

- `nix flake check` builds the full system, so it is slow after an input update. Evaluate first. It leaves out `packages.iso`, which compresses that whole system again; build it with `nix build .#iso` when asked.
- `nix fmt -- --ci` is not read-only: it rewrites unformatted files, then fails.
- The devshell (direnv `use flake`) provides treefmt, deadnix and statix.
- **To prove a cleanup changes nothing**, compare the `drvPath` of the system and every package before and after, and run `nix-diff` on any pair that differs. `install` always changes, because it embeds the flake source. A change that only reorders a list changes the derivation too; compare the sorted package and file sets instead.
- To check a derivation evaluates without building it, use `builtins.unsafeDiscardOutputDependency drv.drvPath`. Writing a plain `drvPath` to a file builds the derivation.

### Rebuilding

The shell aliases come from `inputs.self.lib.rebuild` (`modules/nix/rebuild.nix`):

| Alias                 | Runs                                                                                                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nrs` / `nrb` / `nrt` | `nh os switch` / `boot` / `test` on the flake                                                                                                                                   |
| `nrsd` / `nrbd`       | the same, with `--override-input` pointing each of the user's own inputs at its working tree in `~/Projects`, so uncommitted changes there are built (new files need `git add`) |
| `nrd`                 | `nixos-rebuild dry-build`                                                                                                                                                       |
| `nfu`                 | `write-flake`, then `nix flake update --commit-lock-file`                                                                                                                       |
| `nup`                 | `nfu`, then switch                                                                                                                                                              |
| `ncl`                 | `nh clean all --keep 5 --keep-since 7d`                                                                                                                                         |

Don't switch, test, boot into or update the lock unless asked. Build or evaluate to verify instead. Activating changes the running session, which is the one you are in.

## Runtime traps

Things that pass the checks but go wrong on the running system.

### noctalia

- **The state file shadows nix.** noctalia loads `~/.local/state/noctalia/settings.toml` after the generated `~/.config/noctalia/config.toml`. Anything changed in noctalia's settings GUI is written there and quietly overrides nix. To make nix win again:
  1. rebuild
  2. stop noctalia
  3. remove the stale sections, keeping the `config_version` line
  4. start noctalia

  Editing the file while noctalia runs does nothing: it writes the file back from memory.

- **Lockscreen widgets** must be complete per output: placed for a 1920x1080 output, with a login box on every output (disabled on all but the primary). Otherwise noctalia copies the whole section into its state file. When HDMI-A-1 turns portrait, noctalia saves `lockscreen_widgets` into state anyway, and that is unavoidable. Desktop widgets are off.
- `noctalia config export full` prints the effective config with defaults, which is the fastest way to find a real key name. `noctalia config validate <file>` only warns about unknown keys and still exits 0, so read its output.
- An idle behaviour named in `idle.nix` replaces the default one rather than merging with it. Give it its full action and timeout.
- Blur on noctalia's surfaces comes only from umbriel's layer rules (`modules/programs/noctalia/umbriel/layer-rule.nix`), which need `blur_optimized = false`. noctalia's shadows stay off (`shadow.alpha = 0`), or the blur turns them into a halo.

### umbriel

- The compositor and its portal come from nixpkgs' NixOS module; home-manager only writes `config.toml`.
- Window rules apply in order. A program that draws its own translucency (foot, luciole) needs `opacity = 1.0`, or it is faded twice.
- umbriel's `config validate` rejects `duration_ms` on an animation that uses a spring curve.

### System

- **Firmware** is only what aspire's drivers load (`modules/hosts/aspire/firmware.nix`): i915/xe, the MediaTek MT7961 wifi and bluetooth, Realtek ethernet and SOF audio. New hardware that needs firmware (a USB wifi adapter, a dock) gets its files added there.
- **Impermanence:** `/` is a fresh subvolume on every boot. System state that must survive goes in the preserve lists in `modules/system/impermanence.nix`, and previous roots stay in `old_roots` for 30 days. `/home`, `/nix`, `/var/log` and `/persist` are kept. Users are immutable (`passwd` does nothing); passwords are files in `/persist/passwords/<user>`.
- Changes to `home.sessionVariables` don't reach a session that is already running.
- home-manager moves a conflicting file it doesn't manage to `<file>.bak`. If that `.bak` already exists, activation fails.
- Programs that need the NVIDIA GPU (prismlauncher, the Bedrock launcher, games) get `nvidiaOffloadWrap` or `nvidiaOffloadEnv`. Everything else stays on the Intel GPU.
- `/mnt/storage` is an external SSD, automounted with `nofail`. Backups (`ssd`) and ComfyUI live there.
- The generated NixOS and home-manager option manuals are off for faster rebuilds; look options up with nixd or the `nixopt` and `hm` search engines.

### Shell

The user's shell is zsh with aliases: `cat` is bat, `ls` is eza and `cd` is zoxide. In commands and scripts use `command cat`, or call the tool you mean directly. Run anything that loops, waits or backgrounds as a bash script with a `timeout`.
