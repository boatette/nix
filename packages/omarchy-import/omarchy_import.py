import argparse
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from pathlib import Path

import tomllib

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
BASE_SCHEMES = (
    REPO / "modules" / "programs" / "nvim" / "lua" / "colourscheme" / "schemes.lua"
)

CATALOG_URL = "https://api.noctalia.dev/palettes"
IMAGES = (".png", ".jpg", ".jpeg", ".webp", ".avif")


class Failure(Exception):
    """Anything the user can fix"""


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


def plan_neovim(spec, palette, joined, mode, slug, choice):
    palette_mode = {"nvim": "palette"}
    shape = spec.get("shape")

    if choice == "palette":
        return palette_mode, {}, "asked for palette mode"

    if joined or choice == "plugin":
        unfit = None
        for plugin in spec.get("plugins", []):
            provider = PROVIDERS.get(plugin.get("repo", "").lower())
            if not provider:
                continue

            scheme = (
                family_scheme(provider, palette, mode)
                if joined
                else resolve_scheme(provider, spec.get("colorscheme"))
            )
            if not scheme:
                unfit = "names %s, but %s is not one of its palettes" % (
                    provider,
                    palette,
                )
                continue

            entry = {"nvim": "plugin", "provider": provider, "scheme": scheme}
            opts = plugin.get("opts") or {}
            opts.pop("colorscheme", None)
            if opts:
                entry["opts"] = opts
            return entry, {}, "%s renders %s" % (provider, palette)

        if unfit:
            return palette_mode, {}, unfit
        repos = ", ".join(p.get("repo", "?") for p in spec.get("plugins", [])) or "none"
        return palette_mode, {}, "no installed plugin for %s" % repos

    if shape in ("colorscheme_file", "inline_function"):
        return (
            {"nvim": "colorscheme", "scheme": slug},
            {"kind": shape, "slug": slug},
            "theme ships its own colorscheme",
        )

    named = spec.get("error") or (
        "names %s" % spec.get("colorscheme")
        if spec.get("colorscheme")
        else "no colorscheme"
    )
    return palette_mode, {}, "%s, but the desktop shows %s" % (named, palette)


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


REGISTRY_HEADER = """-- Themes imported by omarchy-import. Generated do edit not this file.

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


SHIM = """-- Generated by omarchy-import from the theme's own neovim.lua

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


def write_neovim_files(work, plan, slug):
    if not plan:
        return []

    source = work / "neovim.lua"
    written = []

    if plan["kind"] == "colorscheme_file":
        target = OMARCHY_DIR / "colors" / ("%s.lua" % slug)
        target.parent.mkdir(parents=True, exist_ok=True)
        header = "-- Imported verbatim by omarchy-import from the theme's neovim.lua.\n"
        target.write_text(
            header + source.read_text(encoding="utf-8", errors="replace"),
            encoding="utf-8",
        )
        written.append(target)
    else:
        spec_target = OMARCHY_DIR / "specs" / ("%s.lua" % slug)
        spec_target.parent.mkdir(parents=True, exist_ok=True)
        header = "-- Imported verbatim by omarchy-import from the theme's neovim.lua.\n"
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
    if ref:
        command += ["--branch", ref]
    result = subprocess.run(
        command + [url, str(clone)],
        capture_output=True,
        text=True,
        timeout=180,
    )
    if result.returncode != 0:
        raise Failure("git clone failed for %s: %s" % (url, result.stderr.strip()))

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
        entry, files, reason = plan_neovim(
            spec, palette_name, joined, mode, slug, args.nvim
        )

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
                "  neovim    needs a rebuild: nix fmt && nix flake check && run0 nixos-rebuild switch --flake %s"
                % REPO
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


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    if (
        argv
        and argv[0] not in ("match", "list", "import")
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
