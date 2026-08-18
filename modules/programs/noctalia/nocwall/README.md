# nocwall

Sorts wallpapers into their palette folders, and recolours the active wallpaper to match the active colourscheme. Companion to the `auto-theme` plugin, which reads the theme _out of_ the directory a wallpaper lives in — nocwall is what puts it there.

Not a noctalia plugin: a plugin service's only event source is `[hooks]` in `config.toml`, which is a generated read-only store path here, so plugin settings cannot persist and a hook can call an absolute store path directly. Sorting is also a batch job over a directory rather than a shell event handler.

Python 3 standard library only. ImageMagick (`magick`, or `convert`) does the decoding, and `lutgen` does the recolouring; `../nocwall.pkg.nix` wraps all three onto `PATH` so nothing depends on the caller's environment.

## Where things live

```
modules/programs/noctalia/
  nocwall/                  <- this tool
  nocwall.pkg.nix           <- derivation; runs the test suite at build time
  nocwall.nix               <- systemd path unit + timers
  _settings/hooks.nix       <- colors_changed / wallpaper_changed triggers
  plugins/auto-theme/       <- the plugin nocwall must not fight
```

Everything is driven from nix; there is no separate install step. A rebuild is needed for an edit to take effect, and **a new file must be `git add`ed first** or the flake will not see it.

## Use

```sh
nocwall plan                  # dry run over <root>/Dynamic — the default
nocwall apply                 # perform the moves, journalled
nocwall undo                  # reverse the most recent batch
nocwall journal               # list batches

nocwall eval --confusion      # accuracy against the hand-sorted tree
nocwall probe IMAGE...        # clusters and per-palette scores for one file
nocwall palette current|list|show NAME|harvest

nocwall tint                  # recolour the current wallpaper to the active palette
nocwall tint --dry-run        # show the target path and cache decision
nocwall tint gc               # LRU-evict the cache
```

`--root` defaults to `~/Pictures/Wallpapers`. Dot-prefixed directories are skipped wholesale, which covers `.optimised`, `.tinted`, `.dist` and `.git`; the pre-dot names are pruned explicitly for trees not yet renamed. `apply` refuses to sort the whole tree without `--i-mean-it`; the default scope is `Dynamic/`.

## How an image is classified

1. `magick <path>[0] -resize 64x64! ... RGB:-` → 4096 RGB samples. The `[0]` handles animated input; `.svg` is skipped.
2. Mean **CIELAB L\*** decides dark vs light against a threshold of **45**, reusing auto-theme's calibration. Do not substitute a linear-light grey — it does not merely shift the scale, it reorders images.
3. Weighted k-means (k=8, deterministic k-means++ seed) → 8 cluster centers.
4. Each candidate palette scores `Σ wᵢ · minⱼ d(cᵢ, pⱼ)` with `d = √(Δa² + Δb² + 0.35·ΔL²)`.
5. Two gates, both of which must pass, else the file **stays where it is**.

Candidates default to the palettes that already have folders in the tree, so the classifier can never invent a destination.

### Everything is CIELAB

The 0.35 lightness weight, the distance thresholds, and the L\* threshold of 45 were all measured in CIELAB. Oklab's a/b axes are ~100× smaller, so clustering in one space and scoring in the other silently mixes unit systems, and scoring in Oklab throughout voids every constant here. Oklab is available and is arguably the better clustering space, but adopting it means **recalibrating**, not a free upgrade. `tests/test_color.py::test_axes_are_not_lab_scale` guards this.

## The two gates

| gate         | flag             | catches                                           |
| ------------ | ---------------- | ------------------------------------------------- |
| absolute fit | `--max-distance` | "closest to Gruvbox, but still a bad Gruvbox fit" |
| ambiguity    | `--min-margin`   | "could be Rose-Pine or Catppuccin"                |

The absolute-fit gate is the one that is easy to omit and matters most. A photograph of a rainbow parrot has no theme however confident the ranking is.

Measured frontier (119 labelled images, coverage % / precision % on accepted moves):

```
           mm=0.05  mm=0.12  mm=0.20  mm=0.30  mm=0.40
  md=2.5    45/89    45/91    44/92    43/92    42/92
  md=3.8    60/86    59/87    57/88    53/90    50/92
  md=5.0    66/87    66/88    62/89    57/91 <- 51/92
  md=6.5    76/78    70/83    64/87    57/91    51/92
```

Defaults are **`--max-distance 5.0 --min-margin 0.30`**: the best coverage available at ≥90% precision. Precision is worth protecting over coverage — an abstention costs nothing, a misfile has to be noticed and undone by hand.

## Accuracy

Ground truth is the tree itself: `Dark/Nord/x.png` is a labelled example of (dark, Nord). With the gates off, ranking accuracy over 79 dark images in the eight populated classes:

```
top-1 73%   top-2 91%   top-3 97%      mode accuracy 100%
```

Per class: Monochrome 12/12, Nord 12/12, Everforest 10/12, Tokyo-Night 10/12, Gruvbox 2/2, Catppuccin 7/12, Rose-Pine 4/12, Kanagawa 1/5.

Misses are all near neighbours — Rose-Pine↔Catppuccin, Kanagawa↔Nord. `Dark/Rose-Pine` holds 448 of ~700 sorted files and reads as a catch-all, which plausibly depresses its score; `--exclude-class Dark/Rose-Pine` measures without it.

Over the whole tree including the light classes and mode detection, top-1 is 69% and mode accuracy is 92%.

### What it does to a real unsorted pile

On the 585-image `Dynamic/` directory, at the default thresholds: **38 files (6%)** are filed, 512 are rejected as no-fit, 35 as ambiguous.

That is the honest number, and the shape of it matters more than the value. The hand-sorted trees score a median best-distance of ~2.2; the `Dynamic` pile sits far outside that distribution. Those wallpapers were chosen _because_ they suited a theme, whereas `Dynamic` is raw wallhaven output — so most of it genuinely belongs to no palette, and leaving it alone is correct.

At 91% precision the **ambiguity** gate binds, not fit: loosening `--max-distance` from 5.0 to 11.0 only moves 38 → 77 files. Trading precision for volume is the only way to sort substantially more:

```
                        files filed (of 585)   tree precision
  md=5.0  mm=0.30              38   ( 6%)          91%
  md=7.8  mm=0.30              62   (11%)          91%
  md=11.0 mm=0.30              77   (13%)          91%
  md=6.5  mm=0.12             106   (18%)          83%
  md=7.8  mm=0.12             145   (25%)          82%
  md=9.0  mm=0.12             179   (31%)          81%
```

The realistic value is as an ongoing filter on new downloads, not a bulk pile-drainer.

## Two things that were tried and rejected

Both were plausible and both lost on measurement. They remain as flags so the results stay reproducible.

**Bidirectional scoring** (`--lam`) adds a palette→image coverage term, on the argument that palette-to-palette distance is strongly asymmetric (Monochrome→Ayu is 4.7 while Ayu→Monochrome is 32.7). It makes accuracy monotonically worse:

```
  lam    0     0.15   0.3    0.5
  top-1  73%   68%    56%    43%
```

The asymmetry argument holds between two palettes, but an image is under no obligation to contain a palette's full gamut — a forest photo has no red or magenta, and penalising that penalises good wallpapers.

**Separation-normalized ambiguity** (`--alpha`) scales the required margin by how intrinsically separable the two competing palettes are. At matched precision it delivers _less_ coverage than the flat margin (alpha=0.1 → 88% precision at 57% coverage, versus min_margin=0.20 → 87% at 64%). It does reach precision the flat gate cannot (92% at 0.2, 100% at 0.35), so it is worth using if you want near-zero misfiles and accept low volume.

## Palette sources

All four of noctalia's sources resolve to hex colors:

| source    | where the colors live                                          |
| --------- | -------------------------------------------------------------- |
| builtin   | compiled into the noctalia binary — see below                  |
| community | `~/.local/state/noctalia/community-palettes/<UrlEncoded>.json` |
| custom    | `~/.config/noctalia/palettes/<Name>.json`                      |
| wallpaper | `noctalia theme <img> --scheme <s> --<mode>`                   |

Folder names fold through the same rule auto-theme uses (lowercase, strip diacritics, drop non-alphanumerics), so `Rose-Pine` and `Rosé Pine` resolve identically in both tools.

### Builtin palettes come out of the binary

The ten builtins are not on disk and are not in the community catalog. They are a static array — `_ZN8noctalia5theme12_GLOBAL__N_1L9kPalettesE`, 10 entries of stride 1232 — of `u64` name length, `char*` name, then 76 × `float32[4]` RGBA. 76 is 2 modes × 38 roles. `grep` for `mPrimary` finds nothing because they are floats, not hex text.

`harvest.py` reads them with stdlib `struct`, resolving vaddr→offset through the section headers rather than a hardcoded delta, and asserts the stride, entry count, name lengths, all-alpha-1.0, and the exact name list. Those assertions are the upgrade signal: a noctalia build that changes the layout fails loudly instead of emitting plausible-looking wrong colors.

Verified against published upstream values — Ayu `#E6B450`, Catppuccin `#CBA6F7` plus the full Mocha ANSI 16, Dracula `#BD93F9`, Gruvbox `#B8BB26`, Rosé Pine `#EBBCBA`, Tokyo-Night `#7AA2F7` / `#1A1B26` / selection `#283457`. Use `round(f*255)`; truncation is off by one on several. Note Nord's primary is `nord7` `#8FBCBB`, not `nord8`.

Seeds expand to full token maps via `noctalia theme --theme-json`, which runs offline under `env -i` in ~0.2s and writes no state. One caveat: it re-derives `outline` instead of passing `mOutline` through (Catppuccin `#4c4f69` → `#646883`), because it takes the fixed-palette path rather than the builtin one. All 22 `terminal_*` tokens and the core accents pass through verbatim.

## Safety

- **Nothing is ever overwritten.** A destination collision compares fingerprints: identical content is recorded as a duplicate and the source is left alone; different content gets a ` (2)` suffix.
- **The mirror moves too.** `.optimised/` counterparts are matched by stem (the optimiser rewrites extensions) and moved alongside. Files with no counterpart leave the mirror stale — re-run `walls-optimise`. Override the directory name with `--mirror-dir`; the default matches that script's output directory.
- **Journalled before the first rename**, fsynced, append-only. `undo` refuses to restore a file whose fingerprint changed since the move, or whose old path is now occupied.
- **References are repointed.** If the current wallpaper is moved, `nocwall` reissues `noctalia msg wallpaper-set` so the live surface follows and the hooks fire, letting auto-theme re-derive the theme. Dead keys in auto-theme's `dynamic.json` are garbage-collected. Disable with `--no-fixup-refs`.
- **`--settle-secs`** (default 10) skips recently-modified files, so an in-flight wallhaven download is never moved mid-write.

## Tests

```sh
cd nocwall && PYTHONPATH=src python3 -m unittest discover -s tests -t .
```

71 tests. Colour conversions are checked against published CIELAB reference values rather than against this code, and the move tests use real files in a temp tree — the properties worth protecting (never overwrite, restore exactly) are properties of the filesystem operations, and a mock would pass while the real thing clobbered a wallpaper. Tests needing the noctalia binary skip when it is absent.

## Recolouring

`lutgen` remaps every pixel to its nearest palette colour, with `--preserve` so the original luminosity survives (without it dark regions wash out badly). The hald CLUT is generated once per palette and reused: ~57 ms for the LUT, ~24 ms per image after.

**Expect the effect size to vary a lot**, because this is nearest-colour remapping and not hue rotation:

- flat or graphic wallpapers retheme convincingly;
- **Monochrome is always dramatic**, because a palette with no hue forces every colour to collapse;
- photographs can barely change if the palette already contains their dominant hue. A blue image under Gruvbox comes out _teal_, not warm, because Gruvbox holds `#83A598` and `#8EC07C` and nothing in the image is near its oranges. Sweeping `--nearest`, `--lum` and `nearest-neighbor` does not fix this; it is inherent.

### Layout, and the bug it fixes

Tinted files go to a path naming the palette they were tinted **to**:

```
.tinted/<palette_key>/Dark/Nord/aurora-1f3c9a.png
                      ^^^^ ^^^^ active mode and palette
```

This is load-bearing. auto-theme finds the mode and palette folder _anywhere_ in a path, so mirroring the original's relative path — the obvious design — makes it misread its own input: a wallpaper tinted out of `Dynamic/` yields a path ending in `Dynamic`, auto-theme classifies it as a dynamic wallpaper, and answers with `color-scheme-set wallpaper`, reverting the theme the user just chose. Tinting `Dark/Rose-Pine/x.png` to Nord had the same flaw more quietly, producing a path that said Rose-Pine.

Naming by the _active_ palette makes auto-theme's re-derivation agree with the theme already set, so it hits its "already correct, nothing to do" branch and issues nothing. `tests/test_tint.py` reimplements auto-theme's `mapPath` and asserts this for every case, so the regression cannot return silently.

Three redundant loop breaks back it up: the `.tinted/<key>/` identity check, a `target == current` check before setting, and a dedupe window mirroring auto-theme's own.

### When it does nothing

- `theme.source == "wallpaper"` — a hard skip. noctalia derives that palette _from_ the current wallpaper, so tinting would feed a different palette back in on the next pass: an oscillator, not a fixed point. This also means `Dynamic/` wallpapers are never tinted, correctly, since they already match by construction.
- The source cannot be determined. Because the path names the palette rather than the origin, provenance comes from per-output state with `.tinted/manifest.json` as a fallback; if neither knows, it skips rather than guessing, since a wrong guess would recolour the wrong image.
- `.svg` and `.gif` inputs.

### Cache

`.tinted/` _is_ the cache: an output is reused for any later visit to the same (image, palette, parameters), and the generated CLUTs live in `.tinted/.clut/`, so one hidden directory holds everything and can be deleted at any time — costing only time. The key hashes the palette's actual hex colours plus the lutgen parameters, so a re-downloaded palette or a changed `--power` invalidates correctly without a manual purge. `tint gc` never evicts a file currently set as a wallpaper.

## Automation

`../nocwall.nix` declares:

- a **systemd path unit** on `~/Pictures/Wallpapers/Dynamic`, wallhaven's download directory, running `nocwall apply --settle-secs 15`. A path unit rather than a polling plugin because the host Luau API has no filesystem watch, and `PathChanged` costs nothing while idle;
- a **weekly timer** as a safety net for events missed while the session was down;
- a **weekly `tint gc`** to evict stale recoloured wallpapers.

## Feature cache

Descriptors are memoised to `~/.local/state/nocwall/features.json`, keyed by path + mtime + size. Decoding is the entire cost of the pipeline (~134 ms/image wall at 8 workers, ~78 s for 585 images), so the cache is what makes threshold sweeps instant. Bump `FeatureCache.VERSION` when extraction changes.
