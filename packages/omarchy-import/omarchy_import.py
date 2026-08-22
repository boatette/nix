import argparse
import curses
import functools
import json
import math
import os
import queue
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import tomllib
import urllib.error
import urllib.request
from pathlib import Path

HOME = Path.home()


def xdg(var, fallback):
    value = os.environ.get(var)
    return Path(value) if value else HOME / fallback


def noctalia_dir(override, var, fallback):
    value = os.environ.get(override)
    return Path(value) if value else xdg(var, fallback) / "noctalia"


REPO = Path(os.environ.get("OMARCHY_IMPORT_REPO", HOME / "nix"))
WALLPAPERS = Path(os.environ.get("WALLPAPER_DIR", HOME / "Pictures" / "Wallpapers"))
EXTRACTOR = Path(
    os.environ.get(
        "OMARCHY_IMPORT_EXTRACTOR", Path(__file__).resolve().parent / "extract_spec.lua"
    )
)
CACHE = xdg("XDG_CACHE_HOME", ".cache") / "omarchy-import"

NOCTALIA_CONFIG = noctalia_dir("NOCTALIA_CONFIG_HOME", "XDG_CONFIG_HOME", ".config")
LIVE_PALETTES = NOCTALIA_CONFIG / "palettes"

PALETTE_DIR = REPO / "modules" / "programs" / "noctalia" / "palettes"
OMARCHY_DIR = REPO / "modules" / "programs" / "nvim" / "omarchy"
REGISTRY = OMARCHY_DIR / "schemes.lua"
PLUGINS = OMARCHY_DIR / "plugins.nix"
BASE_SCHEMES = (
    REPO / "modules" / "programs" / "nvim" / "lua" / "colourscheme" / "schemes.lua"
)

CATALOG_URL = "https://api.noctalia.dev/palettes"
IMAGES = (".png", ".jpg", ".jpeg", ".webp", ".avif")


class Failure(Exception):
    pass


hex = re.compile(r"^#?([0-9a-fa-f]{3}|[0-9a-fa-f]{6})$")


HEX = re.compile(r"^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$")


def parse_hex(value):
    if not isinstance(value, str):
        return None
    match = HEX.match(value.strip().strip("'\""))
    if not match:
        return None
    digits = match.group(1)
    if len(digits) == 3:
        digits = "".join(c * 2 for c in digits)
    return tuple(int(digits[i : i + 2], 16) for i in (0, 2, 4))


def to_hex(rgb):
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(c))) for c in rgb)


def linearise(channel):
    c = channel / 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


_LAB_CACHE = {}


def to_lab(rgb):
    if rgb in _LAB_CACHE:
        return _LAB_CACHE[rgb]

    r, g, b = (linearise(c) for c in rgb)
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883

    def f(t):
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116

    fx, fy, fz = f(x), f(y), f(z)
    lab = (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))
    _LAB_CACHE[rgb] = lab
    return lab


def distance(first, second):
    la, aa, ba = to_lab(first)
    lb, ab, bb = to_lab(second)
    return math.sqrt((aa - ab) ** 2 + (ba - bb) ** 2 + 0.35 * (la - lb) ** 2)


def luminance(rgb):
    r, g, b = (linearise(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(first, second):
    a, b = luminance(first), luminance(second)
    lo, hi = min(a, b), max(a, b)
    return (hi + 0.05) / (lo + 0.05)


def chroma(rgb):
    _, a, b = to_lab(rgb)
    return math.sqrt(a * a + b * b)


def hue(rgb):
    _, a, b = to_lab(rgb)
    return math.degrees(math.atan2(b, a)) % 360


def hue_gap(first, second):
    delta = abs(hue(first) - hue(second)) % 360
    return min(delta, 360 - delta)


def mix(first, second, amount):
    return tuple(a + (b - a) * amount for a, b in zip(first, second))


def is_light(rgb):
    return to_lab(rgb)[0] > 50


def readable_on(colour, dark, light):
    return dark if contrast(colour, dark) >= contrast(colour, light) else light


ANSI = ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white")


def read_toml(path):
    try:
        with path.open("rb") as handle:
            return tomllib.load(handle)
    except (OSError, tomllib.TOMLDecodeError):
        return None


def read_keyed(path, separators):
    entries = {}
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return entries

    for line in text.splitlines():
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        for separator in separators:
            if separator in line:
                key, value = line.split(separator, 1)
                entries.setdefault(key.strip(), value.strip())
                break
    return entries


def from_colors_toml(root):
    data = read_toml(root / "colors.toml")
    if not data:
        return None

    theme = {
        "background": parse_hex(data.get("background")),
        "foreground": parse_hex(data.get("foreground")),
        "cursor": parse_hex(data.get("cursor")),
        "selection_bg": parse_hex(data.get("selection_background")),
        "selection_fg": parse_hex(data.get("selection_foreground")),
        "accent": parse_hex(data.get("accent")),
        "colors": [parse_hex(data.get("color%d" % i)) for i in range(16)],
        "mode": data.get("mode"),
    }
    return (
        theme
        if theme["background"] and theme["foreground"] and theme["colors"][0]
        else None
    )


SEMANTIC = (
    ("dark_background", "darker_background", "background"),
    ("red",),
    ("green",),
    ("yellow",),
    ("blue",),
    ("magenta",),
    ("cyan",),
    ("light_foreground", "foreground"),
    ("muted", "dark_foreground"),
    ("bright_red", "red"),
    ("bright_green", "green"),
    ("bright_yellow", "yellow"),
    ("bright_blue", "blue"),
    ("bright_magenta", "magenta"),
    ("bright_cyan", "cyan"),
    ("bright_foreground", "foreground"),
)


def from_semantic_toml(root):
    data = read_toml(root / "colors.toml")
    if not data or "color0" in data:
        return None

    def first(names):
        for name in names:
            colour = parse_hex(data.get(name))
            if colour:
                return colour
        return None

    theme = {
        "background": parse_hex(data.get("background")),
        "foreground": parse_hex(data.get("foreground")),
        "cursor": first(("cursor", "bright_foreground", "foreground")),
        "selection_bg": first(("selection", "lighter_background")),
        "selection_fg": first(("bright_foreground", "foreground")),
        "surface_variant": first(("lighter_background",)),
        "accent": parse_hex(data.get("accent")),
        "colors": [first(names) for names in SEMANTIC],
        "mode": data.get("mode"),
    }
    return (
        theme
        if theme["background"] and theme["foreground"] and all(theme["colors"][:8])
        else None
    )


def from_alacritty(root):
    data = read_toml(root / "alacritty.toml")
    if not data:
        return None

    colors = data.get("colors")
    if not isinstance(colors, dict):
        return None

    primary = colors.get("primary", {})
    cursor = colors.get("cursor", {})
    selection = colors.get("selection", {})
    normal = colors.get("normal", {})
    bright = colors.get("bright", {})

    theme = {
        "background": parse_hex(primary.get("background")),
        "foreground": parse_hex(primary.get("foreground")),
        "cursor": parse_hex(cursor.get("cursor")),
        "cursor_text": parse_hex(cursor.get("text")),
        "selection_bg": parse_hex(selection.get("background")),
        "selection_fg": parse_hex(selection.get("text")),
        "accent": None,
        "colors": [parse_hex(normal.get(name)) for name in ANSI]
        + [parse_hex(bright.get(name)) for name in ANSI],
    }
    return theme if theme["background"] and theme["foreground"] else None


def from_ghostty(root):
    for name in ("ghostty.conf", "ghostty-theme", "ghostty"):
        path = root / name
        if not path.is_file():
            continue

        entries = read_keyed(path, ("=",))
        palette = [None] * 16
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue

        for index, value in re.findall(
            r"^\s*palette\s*=\s*(\d+)\s*=\s*(\S+)", text, re.MULTILINE
        ):
            slot = int(index)
            if 0 <= slot < 16:
                palette[slot] = parse_hex(value)

        theme = {
            "background": parse_hex(entries.get("background")),
            "foreground": parse_hex(entries.get("foreground")),
            "cursor": parse_hex(entries.get("cursor-color")),
            "selection_bg": parse_hex(entries.get("selection-background")),
            "selection_fg": parse_hex(entries.get("selection-foreground")),
            "accent": None,
            "colors": palette,
        }
        if theme["background"] and theme["foreground"]:
            return theme
    return None


def from_kitty(root):
    path = root / "kitty.conf"
    if not path.is_file():
        return None

    entries = read_keyed(path, (" ", "\t"))
    theme = {
        "background": parse_hex(entries.get("background")),
        "foreground": parse_hex(entries.get("foreground")),
        "cursor": parse_hex(entries.get("cursor")),
        "selection_bg": parse_hex(entries.get("selection_background")),
        "selection_fg": parse_hex(entries.get("selection_foreground")),
        "accent": None,
        "colors": [parse_hex(entries.get("color%d" % i)) for i in range(16)],
    }
    return theme if theme["background"] and theme["foreground"] else None


def extract_theme(root):
    for reader in (
        from_colors_toml,
        from_semantic_toml,
        from_alacritty,
        from_ghostty,
        from_kitty,
    ):
        theme = reader(root)
        if theme:
            break
    else:
        raise Failure(
            "no palette found - looked for colors.toml, alacritty.toml, ghostty.conf and kitty.conf in %s"
            % root
        )

    background, foreground = theme["background"], theme["foreground"]
    colors = theme["colors"]

    if not all(colors[:8]):
        raise Failure("theme is missing some of the eight normal ANSI colours")

    for slot in range(8, 16):
        if not colors[slot]:
            colors[slot] = mix(colors[slot - 8], foreground, 0.25)

    theme["cursor"] = theme.get("cursor") or foreground
    theme["cursor_text"] = theme.get("cursor_text") or background
    theme["selection_bg"] = theme.get("selection_bg") or mix(
        background, foreground, 0.25
    )
    theme["selection_fg"] = theme.get("selection_fg") or foreground
    declared = (theme.get("mode") or "").strip().lower()
    if declared in ("light", "dark"):
        theme["light"] = declared == "light"
    else:
        theme["light"] = (root / "light.mode").exists() or is_light(background)
    return theme


ACCENT_ORDER = (4, 5, 2, 6, 3)


def pick_accents(theme):
    colors = theme["colors"]
    slots = [colors[i] for i in ACCENT_ORDER if colors[i]]
    boldest = max(slots, key=chroma) if slots else None

    accent = theme.get("accent")
    if (
        accent
        and boldest
        and (distance(accent, theme["foreground"]) < 6 or chroma(accent) < 8)
    ):
        accent = None

    chosen = []
    if accent:
        chosen.append(accent)
    elif boldest:
        chosen.append(boldest)

    for colour in (
        slots + [c for c in colors[1:7] if c] + [c for c in colors[9:15] if c]
    ):
        if len(chosen) >= 3:
            break
        if all(distance(colour, picked) > 8 for picked in chosen):
            chosen.append(colour)

    while len(chosen) < 3:
        chosen.append(chosen[-1] if chosen else theme["foreground"])

    return chosen[:3]


def build_variant(theme):
    background, foreground = theme["background"], theme["foreground"]
    colors = theme["colors"]
    primary, secondary, tertiary = pick_accents(theme)
    error = colors[1]

    variant = theme.get("surface_variant")
    if not variant:
        variant = (
            colors[0]
            if distance(colors[0], background) > 4
            else mix(background, foreground, 0.06)
        )

    outline = (
        colors[8]
        if contrast(colors[8], background) > 1.6
        else mix(background, foreground, 0.35)
    )

    return {
        "mPrimary": to_hex(primary),
        "mOnPrimary": to_hex(readable_on(primary, background, foreground)),
        "mSecondary": to_hex(secondary),
        "mOnSecondary": to_hex(readable_on(secondary, background, foreground)),
        "mTertiary": to_hex(tertiary),
        "mOnTertiary": to_hex(readable_on(tertiary, background, foreground)),
        "mError": to_hex(error),
        "mOnError": to_hex(readable_on(error, background, foreground)),
        "mSurface": to_hex(background),
        "mOnSurface": to_hex(foreground),
        "mSurfaceVariant": to_hex(variant),
        "mOnSurfaceVariant": to_hex(mix(foreground, variant, 0.25)),
        "mOutline": to_hex(outline),
        "mShadow": to_hex(mix(background, (0, 0, 0), 0.5)),
        "mHover": to_hex(mix(background, foreground, 0.08)),
        "mOnHover": to_hex(foreground),
        "terminal": {
            "background": to_hex(background),
            "foreground": to_hex(foreground),
            "cursor": to_hex(theme["cursor"]),
            "cursorText": to_hex(theme["cursor_text"]),
            "selectionBg": to_hex(theme["selection_bg"]),
            "selectionFg": to_hex(theme["selection_fg"]),
            "normal": {name: to_hex(colors[i]) for i, name in enumerate(ANSI)},
            "bright": {name: to_hex(colors[i + 8]) for i, name in enumerate(ANSI)},
        },
    }


WHITE, BLACK = (255, 255, 255), (0, 0, 0)


def swap_mode(theme):
    to_light = not is_light(theme["background"])
    background = mix(theme["foreground"], WHITE if to_light else BLACK, 0.8)
    foreground = mix(theme["background"], BLACK if to_light else WHITE, 0.2)

    def settle(colour):
        adjusted = colour
        for _ in range(24):
            if contrast(adjusted, background) >= 4.5:
                break
            adjusted = mix(adjusted, foreground, 0.08)
        return adjusted

    flipped = dict(theme)
    flipped["background"] = background
    flipped["foreground"] = foreground
    flipped["surface_variant"] = mix(background, foreground, 0.06)
    flipped["accent"] = settle(theme["accent"]) if theme.get("accent") else None
    flipped["colors"] = [
        c if i in (0, 7, 8, 15) else settle(c) for i, c in enumerate(theme["colors"])
    ]
    flipped["cursor"] = foreground
    flipped["cursor_text"] = background
    flipped["selection_bg"] = mix(background, foreground, 0.25)
    flipped["selection_fg"] = foreground
    return build_variant(flipped)


ROLES = ("primary", "secondary", "tertiary", "error", "surface", "surfaceVariant")

BUILTIN = {
    "Tokyo-Night": ("#7aa2f7", "#bb9af7", "#9ece6a", "#f7768e", "#1a1b26", "#24283b"),
    "Catppuccin": ("#8aadf4", "#c6a0f6", "#8bd5ca", "#ed8796", "#24273a", "#363a4f"),
    "Nord": ("#88c0d0", "#81a1c1", "#a3be8c", "#bf616a", "#2e3440", "#3b4252"),
    "Dracula": ("#bd93f9", "#ff79c6", "#8be9fd", "#ff5555", "#282a36", "#44475a"),
    "Gruvbox": ("#83a598", "#d3869b", "#fabd2f", "#fb4934", "#282828", "#3c3836"),
    "Rosé Pine": ("#c4a7e7", "#ebbcba", "#9ccfd8", "#eb6f92", "#191724", "#1f1d2e"),
    "Kanagawa": ("#7e9cd8", "#957fb8", "#7aa89f", "#e82424", "#1f1f28", "#2a2a37"),
    "Ayu": ("#39bae6", "#aad94c", "#e6b450", "#d95757", "#0b0e14", "#1e222a"),
    "Eldritch": ("#a48cf2", "#37f499", "#04d1f9", "#f16c75", "#212337", "#323449"),
    "Noctalia": ("#c7a1d8", "#a1b8d8", "#d8a1a1", "#e06c75", "#1c1822", "#272231"),
}


def normalise(name):
    folded = name.lower()
    for source, target in (
        ("é", "e"),
        ("è", "e"),
        ("ê", "e"),
        ("á", "a"),
        ("à", "a"),
        ("ö", "o"),
        ("ü", "u"),
    ):
        folded = folded.replace(source, target)
    return re.sub(r"[^a-z0-9]", "", folded)


def fetch_catalog(offline):
    cached = CACHE / "palettes.json"
    if not offline:
        try:
            with urllib.request.urlopen(CATALOG_URL, timeout=15) as response:
                data = json.loads(response.read().decode("utf-8"))
            CACHE.mkdir(parents=True, exist_ok=True)
            cached.write_text(json.dumps(data), encoding="utf-8")
            return data
        except (urllib.error.URLError, OSError, ValueError, TimeoutError):
            pass

    if cached.is_file():
        try:
            return json.loads(cached.read_text(encoding="utf-8"))
        except ValueError:
            pass
    return []


def roles_from_palette(payload, mode):
    variant = payload.get(mode) or payload.get("dark") or payload.get("light")
    if not isinstance(variant, dict):
        return None

    keys = (
        "mPrimary",
        "mSecondary",
        "mTertiary",
        "mError",
        "mSurface",
        "mSurfaceVariant",
    )
    colours = [parse_hex(variant.get(key)) for key in keys]
    return colours if all(colours) else None


def custom_palettes():
    found = {}
    for directory in (PALETTE_DIR, NOCTALIA_CONFIG / "palettes"):
        if not directory.is_dir():
            continue
        for path in sorted(directory.glob("*.json")):
            try:
                found[path.stem] = json.loads(path.read_text(encoding="utf-8"))
            except (OSError, ValueError):
                continue
    return found


def palette_distance(target, candidate):
    return sum(
        min(distance(role, colour) for colour in target) for role in candidate
    ) / len(candidate)


def signature(theme, variant):
    colours = [parse_hex(variant["mSurface"]), parse_hex(variant["mSurfaceVariant"])]
    colours += [c for c in theme["colors"][1:7] if c]
    if theme.get("accent"):
        colours.append(theme["accent"])
    return colours


def rank(target, mode, offline):
    candidates = []
    if mode == "dark":
        for name, colours in BUILTIN.items():
            candidates.append(("builtin", name, [parse_hex(c) for c in colours]))

    for entry in fetch_catalog(offline):
        payload = entry.get(mode) or entry.get("dark") or {}
        colours = [parse_hex(payload.get(role)) for role in ROLES]
        if all(colours):
            candidates.append(("community", entry.get("name", "?"), colours))

    for name, payload in custom_palettes().items():
        colours = roles_from_palette(payload, mode)
        if colours:
            candidates.append(("custom", name, colours))

    scored = [
        (palette_distance(target, colours), source, name)
        for source, name, colours in candidates
    ]
    scored.sort()
    return scored


PROVIDERS = {
    "folke/tokyonight.nvim": "tokyonight",
    "catppuccin/nvim": "catppuccin",
    "catppuccin/catppuccin.nvim": "catppuccin",
    "rose-pine/neovim": "rose-pine",
    "rosepinetheme/neovim": "rose-pine",
    "rebelot/kanagawa.nvim": "kanagawa",
    "shaunsingh/nord.nvim": "nord",
    "gbprod/nord.nvim": "nord",
    "arcticicestudio/nord-vim": "nord",
    "neanias/everforest-nvim": "everforest",
    "sainnhe/everforest": "everforest",
    "idr4n/github-monochrome.nvim": "github-monochrome",
}

SCHEMES = {
    "tokyonight": [
        "tokyonight-moon",
        "tokyonight-night",
        "tokyonight-storm",
        "tokyonight-day",
        "tokyonight",
    ],
    "catppuccin": [
        "catppuccin-macchiato",
        "catppuccin-mocha",
        "catppuccin-frappe",
        "catppuccin-latte",
        "catppuccin",
    ],
    "rose-pine": ["rose-pine-main", "rose-pine-moon", "rose-pine-dawn", "rose-pine"],
    "kanagawa": ["kanagawa-wave", "kanagawa-dragon", "kanagawa-lotus", "kanagawa"],
    "nord": ["nord"],
    "everforest": ["everforest"],
    "github-monochrome": [
        "github-monochrome-zenbones",
        "github-monochrome-light",
        "github-monochrome",
    ],
}

FAMILY = {
    "tokyonight": "Tokyo-Night",
    "catppuccin": "Catppuccin",
    "rose-pine": "Rosé Pine",
    "kanagawa": "Kanagawa",
    "nord": "Nord",
    "everforest": "Everforest",
    "github-monochrome": "Monochrome",
}

VARIANTS = {
    "tokyonight": ("night", "storm", "moon", "day"),
    "catppuccin": ("mocha", "macchiato", "frappe", "latte"),
    "rose-pine": ("dawn", "moon", "main"),
    "kanagawa": ("wave", "dragon", "lotus"),
}


def read_spec(path):
    if not path.is_file():
        return {"shape": "none"}

    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as handle:
        report = Path(handle.name)

    try:
        result = subprocess.run(
            ["lua", str(EXTRACTOR), str(path), str(report)],
            capture_output=True,
            text=True,
            timeout=20,
        )
        if result.returncode != 0 or not report.stat().st_size:
            return {
                "shape": "unknown",
                "error": (result.stderr or "extractor produced nothing").strip(),
            }
        return json.loads(report.read_text(encoding="utf-8"))
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        return {"shape": "unknown", "error": str(error)}
    finally:
        report.unlink(missing_ok=True)


def resolve_scheme(provider, requested):
    available = SCHEMES.get(provider, [])
    if requested in available:
        return requested

    folded = normalise(requested or "")
    for scheme in available:
        if normalise(scheme) == folded:
            return scheme
    return available[0] if available else None


def family_scheme(provider, palette, mode):
    family = FAMILY.get(provider)
    if not family or normalise(family) not in normalise(palette):
        return None

    folded = normalise(palette)
    for variant in VARIANTS.get(provider, ()):
        if variant in folded:
            scheme = resolve_scheme(provider, "%s-%s" % (provider, variant))
            if scheme:
                return scheme

    available = SCHEMES.get(provider, [])
    wanted = "light" if mode == "light" else "dark"
    for scheme in available:
        if (scheme.endswith(("-dawn", "-day", "-latte", "-light"))) == (
            wanted == "light"
        ):
            return scheme
    return available[0] if available else None


def plugin_stem(repo):
    return normalise(re.sub(r"[._-]?n?vim$", "", repo.split("/")[-1], flags=re.IGNORECASE))


def setup_options(spec, plugin):
    direct = {k: v for k, v in (plugin.get("opts") or {}).items() if k != "colorscheme"}
    if direct:
        return direct

    stem = plugin_stem(plugin.get("repo", ""))
    for recorded in spec.get("setups") or []:
        if normalise(recorded.get("module", "")) in (stem, normalise(plugin.get("name") or "")):
            options = recorded.get("options")
            if isinstance(options, dict):
                return {k: v for k, v in options.items() if k != "colorscheme"}
    return {}


def theme_plugin(spec):
    candidates = [p for p in spec.get("plugins", []) if plugin_stem(p.get("repo", "")) not in ("", "lazy")]
    for plugin in candidates:
        if PROVIDERS.get(plugin.get("repo", "").lower()):
            return plugin
    return candidates[0] if candidates else None


def plan_neovim(spec, palette, joined, mode, slug, choice, name):
    palette_mode = {"nvim": "palette"}
    shape = spec.get("shape")

    if choice == "palette":
        return palette_mode, {}, "asked for palette mode"

    if joined:
        unfit = None
        for plugin in spec.get("plugins", []):
            provider = PROVIDERS.get(plugin.get("repo", "").lower())
            if not provider:
                continue

            scheme = family_scheme(provider, palette, mode)
            if not scheme:
                unfit = "names %s, but %s is not one of its palettes" % (provider, palette)
                continue

            entry = {"nvim": "plugin", "provider": provider, "scheme": scheme}
            options = setup_options(spec, plugin)
            if options:
                entry["opts"] = options
            return entry, {}, "%s renders %s" % (provider, palette)

        if unfit:
            return palette_mode, {}, unfit
        return palette_mode, {}, "no installed plugin renders %s" % palette

    if shape in ("colorscheme_file", "inline_function"):
        return (
            {"nvim": "colorscheme", "scheme": slug},
            {"kind": shape, "slug": slug},
            "theme ships its own colorscheme",
        )

    plugin = theme_plugin(spec)
    if plugin:
        repo = plugin["repo"]
        provider = PROVIDERS.get(repo.lower())
        scheme = spec.get("colorscheme") or plugin_stem(repo)
        options = setup_options(spec, plugin)

        if provider:
            entry = {"nvim": "plugin", "provider": provider, "scheme": resolve_scheme(provider, scheme) or scheme}
            if options:
                entry["opts"] = options
            return entry, {}, "%s is already installed" % provider

        entry = {"nvim": "plugin", "scheme": scheme}
        if options:
            entry["module"] = plugin.get("name") or plugin_stem(repo)
            entry["opts"] = options
        return entry, {"kind": "plugin", "repo": repo}, "installs %s" % repo

    return palette_mode, {}, spec.get("error") or "no colorscheme in neovim.lua"


def lua_value(value, indent):
    if isinstance(value, str):
        return '"%s"' % value.replace("\\", "\\\\").replace('"', '\\"')
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, list):
        return "{ " + ", ".join(lua_value(item, indent) for item in value) + " }"
    if isinstance(value, dict):
        if not value:
            return "{}"
        pad = " " * (indent + 4)
        body = "".join(
            "%s%s = %s,\n"
            % (
                pad,
                key if re.match(r"^[A-Za-z_]\w*$", key) else '["%s"]' % key,
                lua_value(item, indent + 4),
            )
            for key, item in value.items()
        )
        return "{\n%s%s}" % (body, " " * indent)
    return "nil"


REGISTRY_HEADER = """-- DO-NOT-EDIT. This file was auto-generated by omarchy-import.

"""


def known_schemes():
    if not BASE_SCHEMES.is_file():
        return set()
    text = BASE_SCHEMES.read_text(encoding="utf-8")
    body = text.split("local SCHEMES = {", 1)[-1].split("\n}", 1)[0]
    return set(re.findall(r"^\s{4}(\w+)\s*=\s*\{", body, re.MULTILINE))


def read_registry():
    if not REGISTRY.is_file():
        return {}

    text = REGISTRY.read_text(encoding="utf-8")
    entries = {}
    for name, body in re.findall(
        r'\["([^"]+)"\]\s*=\s*(\{.*?\n    \}|\{[^\n]*\}),\n', text, re.DOTALL
    ):
        fields = dict(re.findall(r'(\w+)\s*=\s*"([^"]*)"', body))
        entries[name] = fields
    return entries


def write_registry(entries):
    OMARCHY_DIR.mkdir(parents=True, exist_ok=True)
    body = "".join(
        '    ["%s"] = %s,\n' % (name, lua_value(entries[name], 4))
        for name in sorted(entries, key=normalise)
    )
    REGISTRY.write_text("%sreturn {\n%s}\n" % (REGISTRY_HEADER, body), encoding="utf-8")


SHIM = """-- DO-NOT-EDIT. This file was auto-generated by omarchy-import.

local ok, spec = pcall(require, "omarchy.%(slug)s")
if not ok then
    return
end

local apply
local function search(node, seen)
    if type(node) ~= "table" or seen[node] then
        return
    end
    seen[node] = true
    if type(node.opts) == "table" and type(node.opts.colorscheme) == "function" then
        apply = node.opts.colorscheme
    end
    for _, child in pairs(node) do
        search(child, seen)
    end
end

search(spec, {})

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

if apply then
    apply()
end

vim.g.colors_name = "%(slug)s"
"""


PLUGINS_HEADER = """# DO-NOT-EDIT. This file was auto-generated by omarchy-import.
# Use `nix run .#write-flake` to regenerate flake.nix after it changes.
"""


def read_plugins():
    if not PLUGINS.is_file():
        return {}
    return dict(re.findall(r'plugins-([\w-]+) = \{\s*\n\s*url = "([^"]+)";', PLUGINS.read_text(encoding="utf-8")))


def write_plugins(repo=None):
    pinned = read_plugins()
    if repo:
        pinned[re.sub(r"[^a-z0-9]+", "-", repo.split("/")[-1].lower()).strip("-")] = "github:" + repo

    OMARCHY_DIR.mkdir(parents=True, exist_ok=True)
    inputs = "".join(
        '    plugins-%s = {\n      url = "%s";\n      flake = false;\n    };\n' % (n, u)
        for n, u in sorted(pinned.items())
    )
    builds = "".join(
        '        (pkgs.vimUtils.buildVimPlugin {\n          name = "%s";\n          src = inputs.plugins-%s;\n          doCheck = false;\n        })\n' % (n, n)
        for n in sorted(pinned)
    )
    PLUGINS.write_text(
        "%s{ inputs, ... }:\n{\n  flake-file.inputs = {\n%s  };\n\n"
        "  flake.modules.nixvim.nvim =\n    { pkgs, ... }:\n    {\n      extraPlugins = [\n%s      ];\n    };\n}\n"
        % (PLUGINS_HEADER, inputs, builds),
        encoding="utf-8",
    )
    return PLUGINS


def write_neovim_files(work, plan, slug):
    if not plan:
        return []

    source = work / "neovim.lua"
    written = []

    if plan["kind"] == "plugin":
        return [write_plugins(plan["repo"])]

    if plan["kind"] == "colorscheme_file":
        target = OMARCHY_DIR / "colors" / ("%s.lua" % slug)
        target.parent.mkdir(parents=True, exist_ok=True)
        header = "-- DO-NOT-EDIT. Copied verbatim by omarchy-import from the theme's neovim.lua.\n"
        target.write_text(
            header + source.read_text(encoding="utf-8", errors="replace"),
            encoding="utf-8",
        )
        written.append(target)
    else:
        spec_target = OMARCHY_DIR / "specs" / ("%s.lua" % slug)
        spec_target.parent.mkdir(parents=True, exist_ok=True)
        header = "-- DO-NOT-EDIT. Copied verbatim by omarchy-import from the theme's neovim.lua.\n"
        spec_target.write_text(
            header + source.read_text(encoding="utf-8", errors="replace"),
            encoding="utf-8",
        )
        written.append(spec_target)

        shim = OMARCHY_DIR / "colors" / ("%s.lua" % slug)
        shim.parent.mkdir(parents=True, exist_ok=True)
        shim.write_text(SHIM % {"slug": slug}, encoding="utf-8")
        written.append(shim)

    return written


def wallpapers(work, mode, name):
    source = work / "backgrounds"
    images = (
        sorted(
            p for p in source.iterdir() if p.is_file() and p.suffix.lower() in IMAGES
        )
        if source.is_dir()
        else []
    )
    return WALLPAPERS / ("Light" if mode == "light" else "Dark") / name, images


def install_palette(name, payload):
    LIVE_PALETTES.mkdir(parents=True, exist_ok=True)
    target = LIVE_PALETTES / ("%s.json" % name)

    if target.is_symlink():
        target.unlink()

    target.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return target


def copy_wallpapers(target, images):
    target.mkdir(parents=True, exist_ok=True)
    for image in images:
        shutil.copy2(image, target / image.name)


def git_add(paths):
    if not paths:
        return
    try:
        subprocess.run(
            ["git", "-C", str(REPO), "add", "--"] + [str(p) for p in paths],
            capture_output=True,
            check=False,
            timeout=30,
        )
    except (OSError, subprocess.SubprocessError):
        pass


SOURCE_REPO = re.compile(r"^[\w.-]+/[\w.-]+$")


def fetch(source, work, ref=None):
    local = Path(source).expanduser()
    if local.is_dir():
        shutil.copytree(local, work, dirs_exist_ok=True)
        return str(local)

    subdir = None
    if source.startswith("basecamp/omarchy:"):
        subdir = "themes/" + source.split(":", 1)[1]
        url = "https://github.com/basecamp/omarchy"
    elif SOURCE_REPO.match(source):
        url = "https://github.com/" + source
    elif "://" in source or source.startswith("git@"):
        url = source
    else:
        raise Failure(
            "cannot resolve %r - give owner/repo, a git URL, a local path, or basecamp/omarchy:<theme>"
            % source
        )

    clone = work if not subdir else work.parent / "clone"
    command = ["git", "clone", "--depth", "1", "--quiet"]
    if subdir:
        command += ["--filter=blob:none", "--sparse"]
    if ref:
        command += ["--branch", ref]

    result = None
    for attempt in range(3):
        result = subprocess.run(command + [url, str(clone)], capture_output=True, text=True, timeout=300)
        if result.returncode == 0:
            break
        shutil.rmtree(clone, ignore_errors=True)
    if result.returncode != 0:
        raise Failure("git clone failed for %s: %s" % (url, result.stderr.strip()))

    if subdir:
        subprocess.run(["git", "-C", str(clone), "sparse-checkout", "set", subdir],
                       capture_output=True, text=True, timeout=120)

    if subdir:
        inner = clone / subdir
        if not inner.is_dir():
            raise Failure("%s has no %s" % (url, subdir))
        shutil.copytree(inner, work, dirs_exist_ok=True)

    return url


def theme_name(source, override):
    if override:
        return override

    if ":" in source and not source.startswith(("http", "git@")):
        base = source.split(":", 1)[1]
    else:
        base = source.rstrip("/").split("/")[-1]

    base = re.sub(r"\.git$", "", base)
    base = re.sub(r"^omarchy[-_]", "", base, flags=re.IGNORECASE)
    base = re.sub(r"[-_]?theme$", "", base, flags=re.IGNORECASE)
    base = re.sub(r"[-_]?omarchy$", "", base, flags=re.IGNORECASE)
    parts = re.split(r"[-_\s]+", base.strip("-_ ")) or [base]
    return "-".join(part[:1].upper() + part[1:] for part in parts if part) or "Imported"


def show_matches(scored, limit=3):
    for index, (score, source, name) in enumerate(scored[:limit], start=1):
        print("    %d. %-9s %-28s %.1f" % (index, source, name, score))


def choose_match(scored, args):
    if args.new:
        return None
    if args.reuse:
        for _, source, name in scored:
            if normalise(name) == normalise(args.reuse):
                return source, name
        raise Failure(
            "no palette named %r among the builtin, community or custom palettes"
            % args.reuse
        )

    if not sys.stdin.isatty():
        raise Failure(
            "not a terminal - pass --reuse <palette> to join an existing palette, or --new to register one"
        )

    print("\n  Reuse one of these, or register a new palette?")
    show_matches(scored)
    print("    n. register a new palette")
    while True:
        answer = input("  choice [1-3/n]: ").strip().lower()
        if answer in ("n", "new"):
            return None
        if answer in ("1", "2", "3") and int(answer) <= len(scored):
            _, source, name = scored[int(answer) - 1]
            return source, name
        print("  pick 1, 2, 3, or n")


def build_palette(work, args):
    theme = extract_theme(work)
    mode = args.mode or ("light" if theme["light"] else "dark")
    variant = build_variant(theme)

    payload = {"dark" if mode == "dark" else "light": variant}
    if args.synthesize_light:
        payload["light" if mode == "dark" else "dark"] = swap_mode(theme)

    return theme, mode, variant, payload


def command_match(args):
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp) / "theme"
        work.mkdir(parents=True)
        origin = fetch(args.source, work, args.ref)
        theme, mode, variant, _ = build_palette(work, args)

        print("\n  %s" % origin)
        print("  mode      %s" % mode)
        print(
            "  surface   %s   primary %s" % (variant["mSurface"], variant["mPrimary"])
        )
        print("\n  closest existing palettes:")
        show_matches(rank(signature(theme, variant), mode, args.offline), limit=5)
        print()
    return 0


def command_list(_args):
    entries = read_registry()
    palettes = (
        sorted(p.stem for p in PALETTE_DIR.glob("*.json"))
        if PALETTE_DIR.is_dir()
        else []
    )

    if not entries and not palettes:
        print("nothing imported yet")
        return 0

    print("\n  imported themes")
    for name in sorted(entries, key=normalise):
        fields = entries[name]
        print(
            "    %-24s %-11s %s"
            % (name, fields.get("nvim", "?"), fields.get("source", ""))
        )

    if palettes:
        print("\n  palettes registered in %s" % PALETTE_DIR.relative_to(REPO))
        for name in palettes:
            print("    %s" % name)
    print()
    return 0


def command_import(args):
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp) / "theme"
        work.mkdir(parents=True)
        origin = fetch(args.source, work, args.ref)

        name = theme_name(args.source, args.name)
        theme, mode, variant, payload = build_palette(work, args)
        scored = rank(signature(theme, variant), mode, args.offline)

        print("\n  %s" % origin)
        print("  theme     %s (%s)" % (name, mode))
        print(
            "  palette   surface %s   primary %s   error %s"
            % (variant["mSurface"], variant["mPrimary"], variant["mError"])
        )

        reuse = choose_match(scored, args)
        joined = reuse is not None
        palette_source, palette_name = reuse if joined else ("custom", name)

        slug = normalise(palette_name)
        spec = read_spec(work / "neovim.lua")
        entry, files, reason = plan_neovim(spec, palette_name, joined, mode, slug, args.nvim, name)

        print(
            "\n  palette   %s %s%s"
            % (palette_source, palette_name, "" if joined else "  (new)")
        )
        print("  neovim    %s - %s" % (entry["nvim"], reason))

        wallpaper_dir, images = wallpapers(work, mode, palette_name)
        if args.no_wallpapers or not images:
            print("  wallpaper none")
        else:
            print("  wallpaper %d -> %s" % (len(images), wallpaper_dir))

        if args.dry_run:
            print("\n  dry run - nothing written\n")
            return 0

        staged = []

        live = None
        if not joined:
            PALETTE_DIR.mkdir(parents=True, exist_ok=True)
            target = PALETTE_DIR / ("%s.json" % palette_name)
            target.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
            staged.append(target)
            live = install_palette(palette_name, payload)

        if not joined or (entry["nvim"] != "palette" and slug not in known_schemes()):
            entry["source"] = origin
            registry = read_registry()
            registry[palette_name] = entry
            write_registry(registry)
            staged.append(REGISTRY)
            staged.extend(write_neovim_files(work, files, slug))

        if images and not args.no_wallpapers:
            copy_wallpapers(wallpaper_dir, images)

        git_add(staged)

        if live:
            print("\n  palette   installed at %s" % live)
        print("  repo      %d file(s) under %s" % (len(staged), REPO))

        if entry["nvim"] == "palette":
            print("  ready     now - pick a wallpaper from %s" % wallpaper_dir)
        else:
            print(
                "  neovim    needs a rebuild: %snix fmt && run0 nixos-rebuild switch --flake %s"
                % ("nix run .#write-flake && " if files.get("kind") == "plugin" else "", REPO)
            )

        if args.apply:
            apply_now(palette_source, palette_name, mode)
        print()
    return 0


def apply_now(source, name, mode):
    if (
        source == "custom"
        and not (NOCTALIA_CONFIG / "palettes" / ("%s.json" % name)).is_file()
    ):
        print(
            "  not applied: %s is not installed yet - rebuild first, then pick one of its wallpapers"
            % name
        )
        return

    for command in (["theme-mode-set", mode], ["color-scheme-set", source, name]):
        try:
            subprocess.run(
                ["noctalia", "msg"] + command,
                capture_output=True,
                check=False,
                timeout=15,
            )
        except (OSError, subprocess.SubprocessError):
            print("  could not reach noctalia to apply the theme")
            return
    print("  applied: %s %s (%s)" % (source, name, mode))


OFFICIAL = "basecamp/omarchy"
SEARCH = "https://api.github.com/search/repositories?q=omarchy+theme+in:name&sort=stars&per_page=100"
PALETTE_FILES = ("colors.toml", "alacritty.toml", "ghostty.conf", "ghostty-theme", "kitty.conf")
CATALOG = CACHE / "catalog.json"


def http(url, as_json=True):
    request = urllib.request.Request(url, headers={"Accept": "*/*", "User-Agent": "omarchy-import"})
    with urllib.request.urlopen(request, timeout=20) as response:
        body = response.read()
    return json.loads(body.decode("utf-8")) if as_json else body.decode("utf-8", "replace")


def cached_themes():
    try:
        return json.loads(CATALOG.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return []


def fetch_themes(offline):
    if offline or os.environ.get("OMARCHY_IMPORT_NO_NETWORK"):
        return cached_themes()

    themes = []
    try:
        tree = http("https://api.github.com/repos/%s/git/trees/HEAD?recursive=1" % OFFICIAL)
        seen = set()
        for node in tree.get("tree", []):
            parts = node.get("path", "").split("/")
            if len(parts) >= 2 and parts[0] == "themes" and parts[1] not in seen:
                seen.add(parts[1])
                themes.append({"name": parts[1], "source": "%s:%s" % (OFFICIAL, parts[1]), "kind": "official", "info": ""})
    except Exception:
        pass

    try:
        for item in http(SEARCH).get("items", []):
            repo = item["full_name"]
            if repo.lower() == OFFICIAL:
                continue
            themes.append({
                "name": theme_name(repo, None),
                "source": repo,
                "kind": "community",
                "info": "%s* %s" % (item.get("stargazers_count", 0), (item.get("description") or "")[:70]),
            })
    except Exception:
        pass

    themes.sort(key=lambda t: (t["kind"] != "official", t["name"].lower()))
    if themes:
        CACHE.mkdir(parents=True, exist_ok=True)
        CATALOG.write_text(json.dumps(themes), encoding="utf-8")
        return themes
    return cached_themes()


def preview_path(entry):
    return CACHE / "preview" / (re.sub(r"[^a-z0-9]+", "-", entry["source"].lower()) + ".json")


def preview_cached(entry):
    try:
        return json.loads(preview_path(entry).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None


def preview(entry, offline):
    cached = preview_cached(entry)
    if cached is not None or offline:
        return cached

    if entry["kind"] == "official":
        base = "https://raw.githubusercontent.com/%s/HEAD/themes/%s/" % (OFFICIAL, entry["source"].split(":")[1])
    else:
        base = "https://raw.githubusercontent.com/%s/HEAD/" % entry["source"]

    result = None
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        for name in PALETTE_FILES:
            try:
                (work / name).write_text(http(base + name, as_json=False), encoding="utf-8")
            except Exception:
                continue
        try:
            theme = extract_theme(work)
        except Failure as error:
            result = {"error": str(error)}

    if result is None:
        variant = build_variant(theme)
        mode = "light" if theme["light"] else "dark"
        result = {
            "mode": mode,
            "variant": variant,
            "ansi": [to_hex(c) for c in theme["colors"]],
            "matches": [[round(s, 1), src, n] for s, src, n in rank(signature(theme, variant), mode, offline)[:3]],
        }

    target = preview_path(entry)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(result), encoding="utf-8")
    return result


def xterm_palette():
    levels = (0, 95, 135, 175, 215, 255)
    palette = [(0, 0, 0)] * 16
    for r in levels:
        for g in levels:
            for b in levels:
                palette.append((r, g, b))
    for i in range(24):
        grey = 8 + i * 10
        palette.append((grey, grey, grey))
    return palette


XTERM = xterm_palette()


@functools.lru_cache(maxsize=512)
def nearest_colour(hexvalue):
    rgb = parse_hex(hexvalue)
    if not rgb:
        return -1
    return min(range(16, 256), key=lambda i: sum((a - b) ** 2 for a, b in zip(rgb, XTERM[i])))


class Browser:
    def __init__(self, screen, themes, offline):
        self.screen = screen
        self.themes = themes
        self.offline = offline
        self.filter = ""
        self.cursor = 0
        self.top = 0
        self.pairs = {}
        self.message = ""
        self.previews = {}
        self.pending = set()
        self.dirty = False
        self.queue = queue.Queue()
        self.stop = threading.Event()
        threading.Thread(target=self.work, daemon=True).start()

    def work(self):
        while not self.stop.is_set():
            try:
                entry = self.queue.get(timeout=0.2)
            except queue.Empty:
                continue
            try:
                preview(entry, self.offline)
            except Exception:
                pass
            self.pending.discard(entry["source"])
            self.dirty = True

    def look(self, entry):
        key = entry["source"]
        if key in self.previews:
            return self.previews[key]

        data = preview_cached(entry)
        if data is None:
            if key not in self.pending and not self.offline:
                self.pending.add(key)
                self.queue.put(entry)
            return None

        self.previews[key] = data
        return data

    def swatch(self, colour):
        index = nearest_colour(colour)
        if index < 0:
            return curses.A_NORMAL
        if index not in self.pairs:
            slot = len(self.pairs) + 1
            try:
                curses.init_pair(slot, -1, index)
            except curses.error:
                return curses.A_NORMAL
            self.pairs[index] = slot
        return curses.color_pair(self.pairs[index])

    def visible(self):
        if not self.filter:
            return self.themes
        needle = self.filter.lower()
        return [t for t in self.themes if needle in t["name"].lower() or needle in t["source"].lower()]

    def move(self, delta, absolute=None):
        rows = self.visible()
        limit = max(0, len(rows) - 1)
        self.cursor = min(max(0, absolute if absolute is not None else self.cursor + delta), limit)

    def draw(self):
        self.screen.erase()
        height, width = self.screen.getmaxyx()
        rows = self.visible()
        split = max(28, min(44, width // 3))
        listing = height - 3

        self.screen.addnstr(0, 0, " omarchy themes ", width - 1, curses.A_REVERSE | curses.A_BOLD)
        head = "  %d theme%s%s" % (len(rows), "" if len(rows) == 1 else "s", "   /" + self.filter if self.filter else "")
        self.screen.addnstr(0, 17, head, max(1, width - 18), curses.A_REVERSE)

        if self.cursor < self.top:
            self.top = self.cursor
        if self.cursor >= self.top + listing:
            self.top = self.cursor - listing + 1

        for offset in range(listing):
            index = self.top + offset
            if index >= len(rows):
                break
            theme = rows[index]
            mark = "*" if theme["kind"] == "official" else " "
            style = curses.A_REVERSE if index == self.cursor else curses.A_NORMAL
            self.screen.addnstr(offset + 1, 0, "%s %-*s" % (mark, split - 3, theme["name"]), split - 1, style)

        if rows:
            self.detail(rows[self.cursor], split + 1, width - split - 2, height - 3)

        footer = self.message or "  enter install   / filter   j k g G   r refresh   q quit"
        self.screen.addnstr(height - 1, 0, footer.ljust(width - 1), width - 1, curses.A_REVERSE)
        self.screen.refresh()

    def detail(self, theme, left, width, height):
        line = 1

        def put(text, style=curses.A_NORMAL):
            nonlocal line
            if line < height:
                self.screen.addnstr(line, left, text, max(1, width), style)
                line += 1

        put(theme["name"], curses.A_BOLD)
        put(theme["source"])
        if theme.get("info"):
            put(theme["info"], curses.A_DIM)
        put("")

        data = self.look(theme)
        if data is None:
            put("loading..." if not self.offline else "(no preview - offline)", curses.A_DIM)
            return
        if data.get("error"):
            put("no palette found in this repo", curses.A_DIM)
            return

        variant = data["variant"]
        put("mode      %s" % data["mode"])
        put("surface   %s      primary %s" % (variant["mSurface"], variant["mPrimary"]))
        put("")

        if line < height:
            self.screen.addnstr(line, left, "palette   ", max(1, width))
            column = left + 10
            for colour in data["ansi"][:16]:
                if column + 2 < left + width:
                    self.screen.addnstr(line, column, "  ", 2, self.swatch(colour))
                    column += 2
            line += 1
        put("")

        put("closest existing palettes", curses.A_BOLD)
        for score, source, name in data["matches"]:
            put("  %-9s %-26s %.1f" % (source, name[:26], score))
        put("")
        put("this import would", curses.A_BOLD)
        best = data["matches"][0] if data["matches"] else None
        if best and best[0] < 3:
            put("  join %s, add its wallpapers" % best[2])
        else:
            put("  register %s as a new palette" % theme["name"])

    def dialog(self, theme):
        data = self.look(theme) or {}
        matches = data.get("matches", [])
        options = [("new", "register %s as a new palette" % theme["name"])]
        options += [("reuse:%s" % name, "join %s  (%s, %.1f away)" % (name, source, score)) for score, source, name in matches]

        choice = 1 if len(options) > 1 and matches[0][0] < 3 else 0
        nvim, walls = 0, True
        modes = ("auto", "palette", "plugin")
        self.screen.timeout(-1)

        while True:
            self.screen.erase()
            height, width = self.screen.getmaxyx()
            self.screen.addnstr(0, 0, (" install %s " % theme["name"]).ljust(width - 1), width - 1, curses.A_REVERSE | curses.A_BOLD)
            row = 2
            self.screen.addnstr(row, 2, "palette", width - 4, curses.A_BOLD)
            row += 1
            for index, (_, label) in enumerate(options):
                style = curses.A_REVERSE if index == choice else curses.A_NORMAL
                self.screen.addnstr(row, 4, ("> " if index == choice else "  ") + label, width - 6, style)
                row += 1
            row += 1
            self.screen.addnstr(row, 2, "neovim    %s" % "  ".join(
                ("[%s]" if i == nvim else " %s ") % m for i, m in enumerate(modes)), width - 4)
            row += 1
            self.screen.addnstr(row, 2, "wallpaper %s" % ("[yes]" if walls else "[no]"), width - 4)
            row += 2
            self.screen.addnstr(row, 2, "j k palette   h l neovim   space wallpapers   enter install   esc cancel", width - 4, curses.A_DIM)
            self.screen.refresh()

            key = self.screen.getch()
            if key in (27, ord("q")):
                self.screen.timeout(120)
                return None
            if key in (curses.KEY_UP, ord("k")):
                choice = (choice - 1) % len(options)
            elif key in (curses.KEY_DOWN, ord("j")):
                choice = (choice + 1) % len(options)
            elif key in (curses.KEY_LEFT, ord("h")):
                nvim = (nvim - 1) % len(modes)
            elif key in (curses.KEY_RIGHT, ord("l"), ord("n")):
                nvim = (nvim + 1) % len(modes)
            elif key in (ord(" "), ord("w")):
                walls = not walls
            elif key in (10, 13, curses.KEY_ENTER):
                selected = options[choice][0]
                self.screen.timeout(120)
                return argparse.Namespace(
                    source=theme["source"], ref=None, mode=None, offline=self.offline,
                    synthesize_light=False, name=None,
                    reuse=selected.split(":", 1)[1] if selected.startswith("reuse:") else None,
                    new=selected == "new", nvim=modes[nvim], no_wallpapers=not walls,
                    dry_run=False, apply=True, handler=command_import,
                )

    def prompt(self):
        height, _ = self.screen.getmaxyx()
        self.screen.timeout(-1)
        curses.echo()
        self.screen.addnstr(height - 1, 0, "/".ljust(20), 20, curses.A_REVERSE)
        self.filter = self.screen.getstr(height - 1, 1, 40).decode("utf-8", "replace")
        curses.noecho()
        self.screen.timeout(120)
        self.cursor = 0

    def run(self):
        try:
            curses.use_default_colors()
        except curses.error:
            pass
        curses.curs_set(0)
        self.screen.timeout(120)
        self.draw()

        while True:
            key = self.screen.getch()
            if key == -1:
                if self.dirty:
                    self.dirty = False
                    self.draw()
                continue

            rows = self.visible()
            page = max(1, self.screen.getmaxyx()[0] - 4)

            if key == ord("q"):
                self.stop.set()
                return None
            if key == 27:
                if self.filter:
                    self.filter = ""
                    self.cursor = 0
                else:
                    self.stop.set()
                    return None
            elif key in (curses.KEY_DOWN, ord("j"), 14):
                self.move(1)
            elif key in (curses.KEY_UP, ord("k"), 16):
                self.move(-1)
            elif key == ord("g"):
                self.move(0, absolute=0)
            elif key == ord("G"):
                self.move(0, absolute=len(rows) - 1)
            elif key in (4, curses.KEY_NPAGE, 6):
                self.move(page // 2 if key == 4 else page)
            elif key in (21, curses.KEY_PPAGE, 2):
                self.move(-(page // 2) if key == 21 else -page)
            elif key == ord("/"):
                self.prompt()
            elif key == ord("r"):
                self.message = "  refreshing..."
                self.draw()
                shutil.rmtree(CACHE / "preview", ignore_errors=True)
                CATALOG.unlink(missing_ok=True)
                self.previews.clear()
                self.themes = fetch_themes(self.offline)
                self.message = ""
            elif key in (10, 13, curses.KEY_ENTER, ord("l")) and rows:
                request = self.dialog(rows[self.cursor])
                if request:
                    self.stop.set()
                    return request

            self.draw()


def command_browse(args):
    themes = cached_themes()
    if not themes:
        print("  fetching the theme catalog...")
        themes = fetch_themes(args.offline)
    if not themes:
        raise Failure("could not reach the theme catalog, and nothing is cached")

    while True:
        request = curses.wrapper(lambda screen: Browser(screen, themes, args.offline).run())
        if not request:
            return 0
        try:
            command_import(request)
        except Failure as error:
            print("omarchy-import: %s" % error, file=sys.stderr)
        try:
            input("  enter to return to the browser, ctrl-c to stop ")
        except (EOFError, KeyboardInterrupt):
            print()
            return 0


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    if (
        argv
        and argv[0] not in ("match", "list", "import", "browse")
        and not argv[0].startswith("-")
    ):
        argv.insert(0, "import")

    parser = argparse.ArgumentParser(
        prog="omarchy-import",
        description="import an omarchy theme as a noctalia palette, wallpaper folder and neovim entry",
    )
    commands = parser.add_subparsers(dest="command", required=True)

    def add_source(sub):
        sub.add_argument(
            "source",
            help="owner/repo, a git URL, a local path, or basecamp/omarchy:<theme>",
        )
        sub.add_argument(
            "--mode", choices=("dark", "light"), help="override light/dark detection"
        )
        sub.add_argument(
            "--ref",
            help="branch or tag to clone (default: the repo's own default branch)",
        )
        sub.add_argument(
            "--offline",
            action="store_true",
            help="do not refresh the community palette catalog",
        )
        sub.add_argument(
            "--synthesize-light",
            action="store_true",
            help="also derive the opposite-mode variant",
        )

    importer = commands.add_parser("import", help="import a theme")
    add_source(importer)
    importer.add_argument("--name", help="palette and wallpaper folder name")
    importer.add_argument(
        "--reuse",
        metavar="PALETTE",
        help="join an existing palette instead of registering one",
    )
    importer.add_argument(
        "--new", action="store_true", help="register a new palette without prompting"
    )
    importer.add_argument(
        "--nvim",
        choices=("auto", "palette", "plugin"),
        default="auto",
        help="auto follows the palette; plugin forces the theme's own colorscheme plugin",
    )
    importer.add_argument("--no-wallpapers", action="store_true")
    importer.add_argument("--dry-run", action="store_true")
    importer.add_argument(
        "--apply", action="store_true", help="switch noctalia to the theme once written"
    )
    importer.set_defaults(handler=command_import)

    matcher = commands.add_parser(
        "match", help="report the closest existing palettes and stop"
    )
    add_source(matcher)
    matcher.set_defaults(handler=command_match)

    lister = commands.add_parser("list", help="what has been imported")
    lister.set_defaults(handler=command_list)

    browser = commands.add_parser("browse", help="pick through the available themes")
    browser.add_argument("--offline", action="store_true", help="use only what is already cached")
    browser.set_defaults(handler=command_browse)

    args = parser.parse_args(argv)
    try:
        return args.handler(args)
    except Failure as error:
        print("omarchy-import: %s" % error, file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print()
        return 130


if __name__ == "__main__":
    sys.exit(main())
