from __future__ import annotations

import os
import tomllib
from dataclasses import dataclass, field
from pathlib import Path


def state_home() -> Path:
    env = os.environ.get("NOCTALIA_STATE_HOME")
    if env:
        return Path(env)
    return Path.home() / ".local/state/noctalia"


def settings_path() -> Path:
    return state_home() / "settings.toml"


def cache_home() -> Path:
    env = os.environ.get("XDG_CACHE_HOME")
    base = Path(env) if env else Path.home() / ".cache"
    return base / "noctalia"


@dataclass(frozen=True)
class Theme:
    source: str
    mode: str
    builtin: str = ""
    community_palette: str = ""
    custom_palette: str = ""
    wallpaper_scheme: str = ""

    @property
    def selection(self) -> str:
        return {
            "builtin": self.builtin,
            "community": self.community_palette,
            "custom": self.custom_palette,
            "wallpaper": self.wallpaper_scheme,
        }.get(self.source, "")

    @property
    def is_generated(self) -> bool:
        return self.source == "wallpaper"


@dataclass(frozen=True)
class Wallpapers:
    default: str = ""
    last: str = ""
    monitors: dict[str, str] = field(default_factory=dict)

    def targets(self) -> dict[str, str]:
        if self.monitors:
            return dict(self.monitors)
        if self.last:
            return {"": self.last}
        if self.default:
            return {"": self.default}
        return {}


@dataclass(frozen=True)
class Settings:
    theme: Theme
    wallpapers: Wallpapers
    raw: dict


def load(path: Path | str | None = None) -> Settings:
    p = Path(path) if path is not None else settings_path()
    with open(p, "rb") as fh:
        raw = tomllib.load(fh)

    t = raw.get("theme", {})
    theme = Theme(
        source=t.get("source", "builtin"),
        mode=t.get("mode", "dark"),
        builtin=t.get("builtin", ""),
        community_palette=t.get("community_palette", ""),
        custom_palette=t.get("custom_palette", ""),
        wallpaper_scheme=t.get("wallpaper_scheme", ""),
    )

    w = raw.get("wallpaper", {})
    monitors = {
        name: entry.get("path", "")
        for name, entry in (w.get("monitors") or {}).items()
        if entry.get("path")
    }
    wallpapers = Wallpapers(
        default=(w.get("default") or {}).get("path", ""),
        last=(w.get("last") or {}).get("path", ""),
        monitors=monitors,
    )

    return Settings(theme=theme, wallpapers=wallpapers, raw=raw)
