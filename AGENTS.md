# Agent guide

How this flake works and how changes to it are expected to look. The README covers installing, Secure Boot and impermanence from a person's side; this file is for editing the config.

## What this is

A NixOS + home-manager flake for one user (`boatette`) and two hosts:

- `aspire`: the laptop. Intel + NVIDIA under PRIME offload, LUKS + TPM, lanzaboote Secure Boot, and a root that is wiped on every boot.
- `iso`: a minimal installer that carries the flake and `install-host`.

The desktop is [umbriel](https://github.com/noctalia-dev/umbriel), a scrolling Wayland compositor, with [noctalia](https://github.com/noctalia-dev/noctalia-shell) as its shell, bar, lockscreen, launcher and greeter. Everything is themed **Rosé Pine main**.

## How the flake is assembled

The repo follows the dendritic pattern: every file is a flake-parts module, and features are named modules that hosts pick from.

- **Every `.nix` file under `modules/` is imported automatically** by `import-tree`. There are no import lists to update. A path containing `/_` is skipped. Nix only sees files git tracks, so a new file needs `git add` (or `git add -N`) before it exists to the flake.
- **`flake.nix` is generated** by flake-file. Never edit it. An input is declared next to the module that uses it, with `flake-file.inputs.<name> = { ... };`, and `nix run .#write-flake` regenerates `flake.nix` from them all.
- **Features are `flake.modules.<class>.<name>`**, with four classes:
  - `nixos` and `homeManager`: system and user config. A program that needs both defines both under the same name (`dolphin`, `rmpc`, `zsh`, `btop`).
  - `generic`: only `constants`, which is imported into both of the above.
  - `nvf`: neovim configurations (see [Neovim](#neovim)).

  Any number of files can contribute to the same module and the definitions merge. `modules/programs/foot.nix` and `modules/programs/foot/theme.nix` both define `homeManager.foot`.

- **Composition** is a chain of modules that import each other:

  ```
  nixos.aspire  (modules/hosts/aspire/configuration.nix)
  ├── nixos.desktop → nixos.base        (modules/system/types/)
  ├── host features: backup, gaming, impermanence, monitor-autorotate, petal, printing, secure-boot, tailscale
  └── nixos.boatette → homeManager.boatette → homeManager.desktop → homeManager.base
  ```

  To turn a feature on, list its module name in `modules/system/types/base.nix` (every machine), `modules/system/types/desktop.nix` (graphical machines) or the host's `configuration.nix` (one machine).

- **A host feature that also needs user config** pulls its home-manager half in through `home-manager.sharedModules = [ inputs.self.modules.homeManager.<name> ];`, so it stays off for hosts that don't import it. See `modules/services/backup.nix`, `modules/services/petal.nix` and `modules/programs/gaming/steam.nix`.
- **Hosts** are built in `modules/hosts/<host>/flake-parts.nix` with `inputs.self.lib.mkNixos "x86_64-linux" "<host>"`. Every host and home-manager (`useGlobalPkgs`) share one `pkgs` from `modules/nix/nixpkgs.nix`, with unfree allowed and the local overlay applied.
- **Local packages** live in `packages/<name>/package.nix`, picked up by pkgs-by-name: no registration needed, and `callPackage` can also take `inputs`. Each is a flake output (`nix build .#<name>`) and is used in modules as `pkgs.local.<name>`. Shell tools are `writeShellApplication` with the script in `packages/<name>/<name>.sh`, read in with `builtins.readFile`, so shellcheck runs at build time.

## Layout

```
modules/
├── nix/                 how the flake is assembled: inputs, pkgs, overlay, home-manager, rebuild commands
│   └── flake-parts/     flake.lib core helpers, checks, formatter, devshell, systems
├── hosts/
│   ├── monitors.nix     the flake.monitors schema and the monitor helpers
│   ├── aspire/          configuration, hardware, disko, monitors, storage, ...
│   └── iso/
├── system/
│   ├── constants.nix    shared values (see below)
│   ├── types/           base.nix and desktop.nix: which features each kind of machine gets
│   ├── settings/        what every machine gets: boot, locale, users, nix settings, install plan, ...
│   ├── session/         the graphical session: greeter, fonts, audio, graphics, ...
│   ├── appearance/      GTK, Qt/Kvantum, the kde.settings option
│   └── mime/            the mimeHandlers helper
├── services/            systemd services and host features
├── programs/            one file per program, plus a directory for its facets
└── users/               one file per user
packages/                local packages, as pkgs.local.<name>
assets/                  the wallpaper
```

## Constants

`modules/system/constants.nix` defines `flake.constants`, the values more than one module needs. Never hardcode any of these.

| Key                                  | Holds                                                                                                                                           |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `username`, `description`, `email`   | the user account and git identity                                                                                                               |
| `flakeDir`, `repo`                   | where the flake is checked out (`~/nix`), and its GitHub repo                                                                                   |
| `locale`, `timeZone`, `stateVersion` | system basics                                                                                                                                   |
| `keyboard.{layout,options}`          | XKB, shared by the session and the greeter                                                                                                      |
| `fonts.{mono,sans}.{name,size}`      | JetBrainsMono Nerd Font and Inter                                                                                                               |
| `cursor.{name,size}`                 | the Rosé Pine cursor                                                                                                                            |
| `glass.{radius,opacity}`             | the corner radius and translucency of everything (12 and 0.8)                                                                                   |
| `palette.<name>`                     | Rosé Pine main as `rrggbb` without `#`: `base`, `surface`, `overlay`, `muted`, `subtle`, `text`, `love`, `gold`, `rose`, `pine`, `foam`, `iris` |

How to read them:

- Inside a `nixos` or `homeManager` module written as a function, use **`config.constants.<key>`**. `flake.modules.generic.constants` sets that option, and `base` (and `iso`) import it.
- In a module written as a plain attrset, or in an `nvf` module (which has no `constants` option), use **`inputs.self.constants.<key>`**. Examples: `modules/programs/umbriel/appearance.nix`, `modules/programs/nvim/lsp/servers.nix`.

Rules:

- `glass` is the only place to change roundness or translucency. The bar, umbriel's windows and borders, foot, selector and noctalia's widgets all read it. 12 and 0.8 aren't arbitrary: they are what noctalia hardcodes for the parts it doesn't expose.
- `palette` is a fallback for programs with no Rosé Pine port. Write a colour as `"#${palette.rose}"` and add alpha as a hex suffix (`"#${palette.rose}25"`). See `modules/programs/umbriel/colors.nix` and `modules/programs/selector/theme.nix`.
- A new value that several modules need, and that isn't already an option they can read, belongs in constants.

## Monitors

Monitors are data, defined once per host and read by everything that cares about outputs.

- The schema is `options.flake.monitors` in `modules/hosts/monitors.nix`. Each host's data is in `modules/hosts/<host>/monitors.nix`, as `flake.monitors.<host>."<connector>"` with:
  - `mode` (`"1920x1080@144"`, or `null` for the preferred mode), `scale`, `transform` (`0`, `90`, ..., `"flipped-90"`) and `position.{x,y}`
  - `primary`: exactly one monitor per host. Games, the greeter, the lockscreen login box and desktop widgets go on it.
  - `profiles`: named variations that monitor-autorotate switches all monitors between (aspire's HDMI monitor is on a rotating arm). The first profile by name is the layout the compositor starts in. Positions are shifted until none is negative, because XWayland misplaces clients at negative coordinates.
- In home-manager the host is `osConfig.networking.hostName`; in NixOS it is `config.networking.hostName`. The helpers take the host name, or a monitor.

| Helper (`inputs.self.lib.*`)        | Returns                                                                                               |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `primaryMonitor host`               | the primary connector's name; throws if none is marked                                                |
| `startLayout host`                  | every monitor as laid out in the first profile                                                        |
| `monitorProfiles monitors`          | each profile's layout (or a single `default` one)                                                     |
| `logicalSize monitor`               | `{ width; height; }` after rotation and scale                                                         |
| `isPortrait monitor`                | whether the transform turns it sideways                                                               |
| `transformName monitor`             | the transform as umbriel and wlr-randr spell it (`"normal"`, `"90"`, ...)                             |
| `parseMode mode`                    | `{ width; height; refresh; }` as strings                                                              |
| `noctaliaWidget host output widget` | a noctalia lockscreen or desktop widget whose `box` is laid out for 1920x1080, scaled onto the output |

Used by `modules/programs/umbriel/output.nix`, `modules/programs/noctalia/{lockscreen,desktop}-widgets.nix`, `modules/system/session/greeter.nix`, `modules/programs/gaming/steam.nix` (gamescope's resolution and refresh) and `modules/services/monitor-autorotate.nix`. The one known exception is `modules/programs/noctalia/bar.nix`, which names `HDMI-A-1` to shorten the bar when that monitor is portrait.

## Other helpers

`flake.lib` holds shared functions, used as `inputs.self.lib.<name>`. Put a new helper in the file for its domain rather than repeating code across modules.

| Helper                                          | Defined in                         | Does                                                                       |
| ----------------------------------------------- | ---------------------------------- | -------------------------------------------------------------------------- |
| `rebuild flakeDir`                              | `modules/nix/rebuild.nix`          | the rebuild, update and clean commands that aliases, noctalia and nvim run |
| `mimeHandlers { "<app>.desktop" = [ types ]; }` | `modules/system/mime/handlers.nix` | default and added mime associations, for `homeManager.mime`                |
| `qtFont font`                                   | `modules/nix/flake-parts/lib.nix`  | a Qt font string from a `constants.fonts` entry                            |
| `fromINI text`                                  | `modules/nix/flake-parts/lib.nix`  | parses INI into an attrset (used for the KDE colour scheme)                |
| `nvidiaOffloadEnv`                              | `modules/nix/flake-parts/lib.nix`  | the PRIME offload environment variables                                    |
| `nvidiaOffloadWrap pkgs osConfig pkg bin`       | `modules/nix/flake-parts/lib.nix`  | wraps `bin` to run on the dGPU, when the host uses offload                 |
| `mkNixos system name`                           | `modules/nix/flake-parts/lib.nix`  | builds `nixosConfigurations.<name>` from `modules.nixos.<name>`            |
| `nvim.{cmd,lua,mod}`                            | `modules/programs/nvim/lib.nix`    | nvf keymap constructors                                                    |

`modules/system/appearance/kde.nix` also adds a `kde.settings.<file>.<group>.<key>` home-manager option, which writes KDE config files with kwriteconfig6 on activation.

## Conventions

### Files

- **One concern per file, named after what it configures.** A program is `modules/programs/<name>.nix`. Its facets go in `modules/programs/<name>/`, each file adding to the module it concerns:
  - `theme.nix`: its Rosé Pine port
  - `mime.nix`: its file associations, through `mimeHandlers` into `homeManager.mime`
  - `umbriel.nix`: its window and layer rules, into `homeManager.umbriel`

  So an app's window rules live with the app, not in `modules/programs/umbriel/`. That directory only holds the compositor's own settings and the general rules.

- **noctalia is one file per TOML section** in `modules/programs/noctalia/`, named after it: `dock.nix` sets `programs.noctalia.settings.dock`, and `plugin-settings.nix` sets `plugin_settings`. umbriel's settings follow the same pattern in `modules/programs/umbriel/`.
- **Set only what differs from the default.** A value equal to upstream's, or one another module already sets, gets removed. Several commits exist only to do this.

### Theming

- Rosé Pine **main** only. Not moon, not dawn, and no stylix.
- Native ports come first: the official `rose-pine/*` repos, nixpkgs packages, or ports listed on rosepinetheme.com. A port is a non-flake input named `rose-pine-<app>`, declared in that app's `theme.nix` (or its main file) and read from there.
- Only colour things by hand from `constants.palette` when no port exists.
- noctalia uses its builtin `Rosé Pine` scheme, and its community templates are off.

### Flake inputs

- Every flake input sets `inputs.nixpkgs.follows = "nixpkgs"`. Compositor, shell and greeter inputs that brought their own nixpkgs once had a different glibc from the system Mesa, and the greeter boot-looped (2026-10-06).
- A repo that isn't a flake (themes) gets `flake = false`.
- The user's own projects are `git+file:///home/boatette/Projects/<name>` inputs: monitor-autorotate, petal, selector and toothless.
- After adding, removing or changing an input, run `nix run .#write-flake`. The `check-flake-file` check fails while `flake.nix` differs from what it would generate.

### Nix style

- Formatted by nixfmt (`nix fmt`).
- A module function destructures only the arguments it uses, in alphabetical order: `{ config, lib, pkgs, ... }`. deadnix fails the check on unused ones.
- Prefer `inherit (config.constants) fonts;` or `inherit (x) a b;` over repeated paths, and a `let` block for values used more than once.
- Use `lib.getExe pkgs.foo` / `lib.getExe' pkgs.foo "bin"` rather than store paths written out by hand.
- Package lists use `with pkgs; [ ... ]`, plus `++ [ ... ]` for anything not from `pkgs`.
- Separate logical groups with a blank line.
- Put a `/* lua */` annotation before a multi-line Lua string so editors highlight it.
- Use `lib.mkBefore`/`lib.mkAfter` when list order matters. umbriel applies window rules in order, and the general ones in `modules/programs/umbriel/window-rule.nix` are `mkBefore`.

### Comments

- Few of them, lowercase, no trailing full stop.
- Explain **why**: an upstream quirk, where a number came from, what breaks without the line. Never restate what the code says.
- No commented-out config. The only markers are `# TODO:` and `# FIX:`.

### Spelling

Australian/British English in file names, names and prose (`colourscheme.nix`, "visualiser"). Upstream option and key names keep their own spelling (`colors.nix` sets umbriel's `colors`).

### Other languages

- Lua (nvim runtime): stylua, 4 spaces, 120 columns, double quotes, parentheses on every call (`.stylua.toml`).
- Everything else follows `.editorconfig`: 2 spaces, LF, a final newline.
- treefmt also formats Markdown, JSON and YAML (prettier), shell (shfmt), Python (ruff) and TOML (taplo).

### Neovim

neovim is built by nvf from `flake.modules.nvf.*` in `modules/programs/nvim/`:

- `core`: shared by every build, and adds `modules/programs/nvim/runtime/` (Lua under `lua/config/`, snippets under `snippets/`) to the runtime path.
- `nvim`: the daily editor, installed through `homeManager.nvim`.
- `nvim-full`: `nvim` plus heavier languages. Nothing installs it, so the checks only evaluate it.
- `minimal`: the editor for `iso` and `vi`.

Each keymap lives in the file of the plugin it needs and is built with `inputs.self.lib.nvim.{cmd,lua,mod}`.

## Git

The git settings below come from `modules/programs/git.nix` and `modules/programs/git/signing.nix`.

### Commit messages

- [Conventional Commits](https://www.conventionalcommits.org), as a single subject line: `type(scope): summary`. No body.
- The summary is lowercase, has no trailing full stop and stays under about 70 characters (the longest so far is 68). It says what changed in plain words and doesn't have to be imperative:
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

- The scope is the program or module, lowercase and spelled as its file or directory is named: `noctalia`, `umbriel`, `nvim`, `qutebrowser`, `monitor-autorotate`. The older `qute` and `MAR` are not the pattern. Leave the scope out for a change across the whole repo (`refactor: consistency pass`).

### What goes in a commit

- One logical change per commit. A cleanup that touches many programs is a series of scoped commits, not one big one.
- Updating existing inputs is a commit of its own, made by `nix flake update --commit-lock-file` (`nfu`, or `nix flake update <input> --commit-lock-file` for one input). Its message is nix's `flake.lock: Update` with the generated body. Never write one by hand.
- Adding or removing an input is different. The module that declares it, `flake.nix` regenerated by `write-flake`, and the `flake.lock` entry nix writes on the next evaluation all go in one commit (`feat(petal): add the phone app's server`).
- `/result` and `.direnv/` are ignored. Never commit build output.
- Commits and tags are SSH-signed automatically (`commit.gpgsign`, `tag.gpgsign`). Don't pass `--no-gpg-sign`. The `allowedSigners` key in `signing.nix` isn't the local `~/.ssh/id_ed25519` that signs, which is why `git log --show-signature` reports unknown validity. Leave that alone unless asked, and never reuse that key for SSH access.

### Branches and history

- `master` is the only long-lived branch. It is pushed to `origin` (`git@github.com:boatette/nix.git`, private).
- Small changes are committed straight to `master`.
- A larger effort gets its own branch, named after the topic in plain lowercase with no prefix: `sweep`, `niri`, `monitor-autorotate`. That covers a compositor switch, a repo-wide sweep, or a new service that has to run for a while before it's trusted. It is merged back with `git merge --no-ff <branch>`, keeping git's default `Merge branch '<branch>'` message, and then deleted.
- Otherwise history stays linear. `pull.rebase` is on, with `rebase.autoStash` and `rebase.updateRefs`, so `git pull` rebases local commits. `rerere` is on, and conflicts are shown in `zdiff3` style.
- `push.autoSetupRemote` and `push.followTags` are on, so a new branch's first push sets its upstream, and tags travel with the commits.

### What an agent may do

- Commit, branch, merge or push only when asked.
- Never amend, rebase or force-push commits that are already on `origin`.
- Nix only sees files git tracks, so `git add` (or `git add -N`) a new file before building, even if it won't be committed yet.

## Checking a change

| Command                                                                      | What it does                                                                                                                         |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `nix fmt`                                                                    | formats the tree with treefmt                                                                                                        |
| `nix flake check`                                                            | builds every package and host except `iso` and `nvim-full`, evaluates `nvim-full`, and runs deadnix, statix and the formatting check |
| `nix build .#checks.x86_64-linux.<name>`                                     | one check: `statix`, `deadnix`, `formatting`, `check-flake-file`, `eval-nvim-full`, `package-<name>`, `host-aspire`                  |
| `nix eval .#nixosConfigurations.aspire.config.system.build.toplevel.drvPath` | evaluates aspire without building it                                                                                                 |
| `nix build .#nixosConfigurations.aspire.config.system.build.toplevel`        | builds aspire without activating it                                                                                                  |

- `nix flake check` builds the full aspire system, so it is slow after an input update. Evaluate first.
- `nix fmt -- --ci` is not read-only: it rewrites unformatted files, then fails.
- The devshell (direnv `use flake`) provides treefmt, deadnix and statix.
- **To prove a cleanup changes nothing**, compare the `drvPath` of every host and package before and after. Run `nix-diff` on any pair that differs. Two always change for unrelated reasons, so ignore them:
  - `iso`, after any edit, because it embeds the flake source.
  - `nvim-minimal` and `vi`, whenever `modules/programs/nvim/runtime/` changes.
- To check a derivation evaluates without building it, use `builtins.unsafeDiscardOutputDependency drv.drvPath`. Writing a plain `drvPath` to a file builds the derivation.

### Rebuilding

The shell aliases come from `inputs.self.lib.rebuild` (`modules/nix/rebuild.nix`):

| Alias                 | Runs                                                                                                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nrs` / `nrb` / `nrt` | `nh os switch` / `boot` / `test` on the flake                                                                                                                             |
| `nrsd` / `nrbd`       | the same, with `--override-input` pointing each `git+file` input at its working tree, so uncommitted changes in `~/Projects/*` are built (new files there need `git add`) |
| `nrd`                 | `nixos-rebuild dry-build`                                                                                                                                                 |
| `nfu`                 | `write-flake`, then `nix flake update --commit-lock-file`                                                                                                                 |
| `nup`                 | `nfu`, then switch                                                                                                                                                        |
| `ncl`                 | `nh clean all --keep 5 --keep-since 7d`                                                                                                                                   |

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

- **Lockscreen and desktop widgets** must be complete per output. Build them with `noctaliaWidget`, and give every output a login box (disabled on all but the primary). Otherwise noctalia copies the whole section into its state file. When HDMI-A-1 rotates, noctalia saves `lockscreen_widgets` into state anyway, and that is unavoidable.
- `noctalia config export full` prints the effective config with defaults, which is the fastest way to find a real key name. `noctalia config validate <file>` only warns about unknown keys and still exits 0, so read its output.
- An idle behaviour named in `idle.nix` replaces the default one rather than merging with it. Give it its full action and timeout.
- Blur on noctalia's surfaces comes only from umbriel's layer rules (`modules/programs/noctalia/umbriel/layer-rule.nix`), which need `blur_optimized = false`. noctalia's shadows stay off (`shadow.alpha = 0`), or the blur turns them into a halo.

### umbriel

- The home-manager config targets the umbriel NixOS runs: `programs.umbriel.package = osConfig.programs.umbriel.package`. That way the config and `umbriel msg` match the running compositor, not the newer one the flake input carries.
- Window rules apply in order. A program that draws its own translucency (foot, konsole) needs `opacity = 1.0`, or it is faded twice.
- umbriel's `config validate` rejects `duration_ms` on an animation that uses a spring curve.

### System

- **Impermanence:** `/` is a fresh subvolume on every boot. System state that must survive goes in the preserve lists in `modules/system/impermanence.nix`, and previous roots stay in `old_roots` for 30 days. `/home`, `/nix`, `/var/log` and `/persist` are kept. Users are immutable (`passwd` does nothing); passwords are files in `/persist/passwords/<user>`.
- Changes to `home.sessionVariables` don't reach a session that is already running.
- home-manager moves a conflicting file it doesn't manage to `<file>.bak`. If that `.bak` already exists, activation fails.
- Programs that need the NVIDIA GPU (prismlauncher, the Bedrock launcher, games) get `nvidiaOffloadWrap` or `nvidiaOffloadEnv`. Everything else stays on the Intel GPU.
- `/mnt/storage` is an external SSD, automounted with `nofail`. Backups (`ssd`) and ComfyUI live there.

### Shell

The user's shell is zsh with aliases: `cat` is bat, `ls` is eza and `cd` is zoxide. In commands and scripts use `command cat`, or call the tool you mean directly. Run anything that loops, waits or backgrounds as a bash script with a `timeout`.
