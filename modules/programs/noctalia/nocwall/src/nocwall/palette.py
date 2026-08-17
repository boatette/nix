from __future__ import annotations

import json
import os
import subprocess
import unicodedata
from pathlib import Path

from . import harvest, settings


_EXTRA_FOLD = str.maketrans(
    {"ø": "o", "Ø": "o", "æ": "ae", "Æ": "ae", "ß": "ss", "đ": "d", "ł": "l"}
)


def norm(s: str) -> str:
    if not s:
        return ""
    s = s.translate(_EXTRA_FOLD)
    decomposed = unicodedata.normalize("NFKD", s)
    stripped = "".join(c for c in decomposed if not unicodedata.combining(c))
    return "".join(c for c in stripped.lower() if c.isascii() and c.isalnum())


def _url_decode(s: str) -> str:
    out: list[str] = []
    i = 0
    raw = s.encode("utf-8", "surrogateescape")
    while i < len(raw):
        if raw[i] == 0x25 and i + 2 < len(raw):
            try:
                out.append(int(raw[i + 1 : i + 3], 16))
                i += 3
                continue
            except ValueError:
                pass
        out.append(raw[i])
        i += 1
    return bytes(out).decode("utf-8", "replace")


def community_dir() -> Path:
    return settings.state_home() / "community-palettes"


def custom_dirs() -> list[Path]:
    env = os.environ.get("XDG_CONFIG_HOME")
    config = Path(env) if env else Path.home() / ".config"
    return [config / "noctalia/palettes", settings.state_home() / "palettes"]


def _noctalia_bin() -> str:
    return os.environ.get("NOCWALL_NOCTALIA_BIN", "noctalia")


def _palette_data_path() -> str | None:
    return os.environ.get("NOCWALL_PALETTE_DATA")


_builtins_cache: dict[str, dict] | None = None


def builtins(binary: str | None = None) -> dict[str, dict]:
    global _builtins_cache
    if _builtins_cache is not None:
        return _builtins_cache

    data_path = _palette_data_path()
    if data_path and Path(data_path).exists():
        with open(data_path, "rb") as fh:
            _builtins_cache = json.load(fh)
        return _builtins_cache

    path = binary or _resolve_noctalia_elf()
    _builtins_cache = harvest.harvest(path)
    return _builtins_cache


def _resolve_noctalia_elf() -> str:
    env = os.environ.get("NOCWALL_NOCTALIA_ELF")
    if env:
        return env

    from shutil import which

    exe = which(_noctalia_bin())
    if not exe:
        raise harvest.HarvestError(
            "noctalia not found on PATH; set NOCWALL_NOCTALIA_ELF or "
            "NOCWALL_PALETTE_DATA"
        )
    real = Path(exe).resolve()
    wrapped = real.with_name("." + real.name + "-wrapped")
    if wrapped.exists():
        return str(wrapped)
    return str(real)


def load_community() -> dict[str, tuple[str, dict]]:
    out: dict[str, tuple[str, dict]] = {}
    d = community_dir()
    if not d.is_dir():
        return out
    for entry in sorted(d.glob("*.json")):
        name = _url_decode(entry.stem)
        try:
            with open(entry, "rb") as fh:
                data = json.load(fh)
        except (OSError, json.JSONDecodeError):
            continue
        out[norm(name)] = (name, data)
    return out


def load_custom() -> dict[str, tuple[str, dict]]:
    out: dict[str, tuple[str, dict]] = {}
    for d in custom_dirs():
        if not d.is_dir():
            continue
        for entry in sorted(d.glob("*.json")):
            try:
                with open(entry, "rb") as fh:
                    data = json.load(fh)
            except (OSError, json.JSONDecodeError):
                continue
            out.setdefault(norm(entry.stem), (entry.stem, data))
    return out


def seed_for(source: str, name: str, mode: str) -> dict:
    key = norm(name)

    if source == "builtin":
        table = {norm(k): (k, v) for k, v in builtins().items()}
    elif source == "community":
        table = load_community()
    elif source == "custom":
        table = load_custom()
    else:
        raise ValueError(f"{source!r} has no seed; generate it from the image")

    if key not in table:
        raise LookupError(
            f"{source} palette {name!r} not found "
            f"(known: {sorted(v[0] for v in table.values())})"
        )
    _display, data = table[key]

    if mode in data:
        return data[mode]

    if "mPrimary" in data:
        return data
    raise LookupError(f"{source} palette {name!r} has no {mode!r} variant")


def expand(seed: dict, mode: str, *, noctalia: str | None = None) -> dict:
    exe = noctalia or _noctalia_bin()
    payload = json.dumps({mode: seed})
    proc = subprocess.run(
        [exe, "theme", "--theme-json", "/dev/stdin", f"--{mode}"],
        input=payload,
        capture_output=True,
        text=True,
        timeout=30,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"noctalia theme --theme-json failed ({proc.returncode}): "
            f"{proc.stderr.strip()[:400]}"
        )
    return _parse_theme_json(proc.stdout)


def generate_from_image(
    image: str, scheme: str, mode: str, *, noctalia: str | None = None
) -> dict:
    exe = noctalia or _noctalia_bin()
    proc = subprocess.run(
        [exe, "theme", image, "--scheme", scheme, f"--{mode}"],
        capture_output=True,
        text=True,
        timeout=60,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"noctalia theme failed for {image!r} ({proc.returncode}): "
            f"{proc.stderr.strip()[:400]}"
        )
    return _parse_theme_json(proc.stdout)


def _parse_theme_json(text: str) -> dict:
    start = text.find("{")
    if start < 0:
        raise RuntimeError(f"no JSON in noctalia theme output: {text[:200]!r}")
    decoder = json.JSONDecoder()
    obj, _end = decoder.raw_decode(text[start:])
    return obj


TERMINAL_TOKENS = tuple(
    ["terminal_background", "terminal_foreground"]
    + [
        f"terminal_{w}_{c}"
        for w in ("normal", "bright")
        for c in ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white")
    ]
)


def tint_colors(expanded: dict) -> list[str]:
    colors = expanded.get("colors", expanded)
    out: list[str] = []
    for token in TERMINAL_TOKENS:
        value = colors.get(token)
        if isinstance(value, dict):
            value = value.get("hex") or value.get("default")
        if isinstance(value, str) and value.startswith("#"):
            if value not in out:
                out.append(value)
    return out


def current(
    st: settings.Settings | None = None, *, noctalia: str | None = None
) -> dict:
    st = st or settings.load()
    theme = st.theme

    if theme.is_generated:
        image = st.wallpapers.last or st.wallpapers.default
        if not image:
            raise LookupError("theme.source is 'wallpaper' but no wallpaper is set")
        return generate_from_image(
            image, theme.wallpaper_scheme or "vibrant", theme.mode, noctalia=noctalia
        )

    seed = seed_for(theme.source, theme.selection, theme.mode)
    return expand(seed, theme.mode, noctalia=noctalia)
