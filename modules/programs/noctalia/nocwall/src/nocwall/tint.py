from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path

from . import palette, settings

TINT_DIR = ".tinted"


CLUT_SUBDIR = ".clut"

MANIFEST = "manifest.json"


SETTLE_MS = 4500


DEDUPE_MS = 1500

DEFAULT_ALGORITHM = "shepards-method"
DEFAULT_POWER = 4.0
DEFAULT_NEAREST = 16
DEFAULT_LUM = 1.0

SKIP_SUFFIXES = {".svg", ".gif"}


class TintError(RuntimeError):
    pass


@dataclass
class Params:
    algorithm: str = DEFAULT_ALGORITHM
    preserve: bool = True
    power: float = DEFAULT_POWER
    nearest: int = DEFAULT_NEAREST
    lum: float = DEFAULT_LUM

    def key_part(self) -> str:
        return json.dumps(
            {
                "algorithm": self.algorithm,
                "preserve": self.preserve,
                "power": self.power,
                "nearest": self.nearest,
                "lum": self.lum,
            },
            sort_keys=True,
        )


def state_dir() -> Path:
    env = os.environ.get("XDG_STATE_HOME")
    base = Path(env) if env else Path.home() / ".local/state"
    return base / "nocwall"


def cache_dir() -> Path:
    env = os.environ.get("XDG_CACHE_HOME")
    base = Path(env) if env else Path.home() / ".cache"
    return base / "nocwall"


def lutgen_bin() -> str:
    return os.environ.get("NOCWALL_LUTGEN", "lutgen")


def have_lutgen() -> bool:
    return shutil.which(lutgen_bin()) is not None


def palette_key(
    hexes: list[str], mode: str, source: str, selection: str, params: Params
) -> str:
    h = hashlib.sha256()
    h.update(json.dumps([c.lower() for c in hexes], sort_keys=True).encode())
    h.update(f"|{mode}|{source}|{selection}|".encode())
    h.update(params.key_part().encode())
    digest = h.hexdigest()[:10]
    safe = "".join(c if c.isalnum() else "-" for c in (selection or source))[:24]
    return f"{source}-{safe}-{mode}-{digest}"


def source_fingerprint(path: Path) -> str:
    st = os.stat(path)
    h = hashlib.sha256()
    h.update(str(st.st_size).encode())
    with open(path, "rb") as fh:
        h.update(fh.read(1 << 20))
    return h.hexdigest()[:16]


def is_tinted(path: Path, root: Path) -> bool:
    try:
        rel = path.relative_to(root)
    except ValueError:
        return False
    return rel.parts[:1] == (TINT_DIR,)


def tinted_key(path: Path, root: Path) -> str | None:
    try:
        rel = path.relative_to(root)
    except ValueError:
        return None
    if rel.parts[:1] != (TINT_DIR,) or len(rel.parts) < 3:
        return None
    return rel.parts[1]


def manifest_path(root: Path) -> Path:
    return root / TINT_DIR / MANIFEST


def load_manifest(root: Path) -> dict[str, str]:
    try:
        with open(manifest_path(root)) as fh:
            data = json.load(fh)
        return data if isinstance(data, dict) else {}
    except (OSError, ValueError):
        return {}


def record_manifest(root: Path, tinted: Path, source: Path) -> None:
    data = load_manifest(root)
    data[str(tinted)] = str(source)
    p = manifest_path(root)
    p.parent.mkdir(parents=True, exist_ok=True)
    tmp = p.with_suffix(".tmp")
    try:
        with open(tmp, "w") as fh:
            json.dump(data, fh, indent=1)
        os.replace(tmp, p)
    except OSError:
        pass


def original_of(path: Path, root: Path) -> Path | None:
    if not is_tinted(path, root):
        return path
    recorded = load_manifest(root).get(str(path))
    if recorded and Path(recorded).exists():
        return Path(recorded)
    return None


def _palette_folder(selection: str, source: str) -> str:
    name = (selection or source or "palette").strip()
    return name.replace("/", "-").replace("\\", "-") or "palette"


def tinted_path(
    original: Path, root: Path, key: str, mode: str, selection: str, source: str
) -> Path:
    mode_dir = "Light" if mode == "light" else "Dark"
    folder = _palette_folder(selection, source)

    tag = hashlib.sha256(str(original).encode()).hexdigest()[:6]

    return root / TINT_DIR / key / mode_dir / folder / f"{original.stem}-{tag}.png"


def _clut_path(key: str, root: Path | None = None) -> Path:
    if root is not None:
        return root / TINT_DIR / CLUT_SUBDIR / f"{key}.png"
    return cache_dir() / "clut" / f"{key}.png"


def ensure_clut(
    key: str, hexes: list[str], params: Params, root: Path | None = None
) -> Path | None:
    out = _clut_path(key, root)
    if out.exists():
        return out
    out.parent.mkdir(parents=True, exist_ok=True)

    cmd = [lutgen_bin(), "generate", "--output", str(out)]
    cmd += _algorithm_args(params)
    cmd += ["--"] + list(hexes)
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
    if proc.returncode != 0 or not out.exists():
        if out.exists():
            out.unlink()
        return None
    return out


def _algorithm_args(params: Params) -> list[str]:
    args: list[str] = []
    algo = params.algorithm
    if algo == "shepards-method":
        args += [
            "--shepards-method",
            "--power",
            str(params.power),
            "--nearest",
            str(params.nearest),
        ]
    elif algo == "gaussian-rbf":
        args += ["--gaussian-rbf", "--nearest", str(params.nearest)]
    elif algo == "nearest-neighbor":
        args += ["--nearest-neighbor"]
    elif algo == "gaussian-sampling":
        args += ["--gaussian-sampling"]
    if params.preserve:
        args += ["--preserve"]
    if params.lum != 1.0:
        args += ["--lum", str(params.lum)]
    return args


def run_lutgen(
    src: Path, dst: Path, hexes: list[str], params: Params, clut: Path | None
) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    tmp = dst.with_suffix(".partial.png")

    cmd = [lutgen_bin(), "apply", "--output", str(tmp)]
    if clut is not None:
        cmd += ["--hald-clut", str(clut), str(src)]
    else:
        cmd += _algorithm_args(params) + [str(src), "--"] + list(hexes)

    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    if proc.returncode != 0 or not tmp.exists():
        if tmp.exists():
            tmp.unlink()
        raise TintError(
            f"lutgen failed on {src.name} ({proc.returncode}): "
            f"{(proc.stderr or proc.stdout).strip()[:300]}"
        )
    os.replace(tmp, dst)


class State:
    def __init__(self, path: Path | None = None):
        self.path = path or (state_dir() / "tint-state.json")
        self.data: dict = {"sources": {}, "last": {}}
        try:
            with open(self.path) as fh:
                loaded = json.load(fh)
            if isinstance(loaded, dict):
                self.data.update(loaded)
        except (OSError, ValueError):
            pass

    def save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.path.with_suffix(".tmp")
        with open(tmp, "w") as fh:
            json.dump(self.data, fh, indent=1)
        os.replace(tmp, self.path)

    def source_for(self, connector: str, current: Path, root: Path) -> Path | None:
        if not is_tinted(current, root):
            return current
        remembered = self.data["sources"].get(connector or "_all")
        if remembered and Path(remembered).exists():
            return Path(remembered)
        return original_of(current, root)

    def remember(self, connector: str, source: Path):
        self.data["sources"][connector or "_all"] = str(source)

    def should_dedupe(self, token: str, window_ms: int = DEDUPE_MS) -> bool:
        now = time.time() * 1000
        prev = self.data["last"].get(token)
        if prev is not None and now - prev < window_ms:
            return True
        self.data["last"][token] = now
        return False

    def mark_pending(self, connector: str, path: str):
        self.data.setdefault("pending", {})[connector or "_all"] = {
            "path": path,
            "at": time.time() * 1000,
        }

    def take_pending(self) -> dict:
        p = self.data.pop("pending", {})
        return p


class Lock:
    def __init__(self, path: Path | None = None, stale_secs: int = 120):
        self.path = path or (state_dir() / "tint.lock")
        self.stale = stale_secs
        self.fd = None

    def acquire(self) -> bool:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        try:
            if self.path.exists():
                age = time.time() - self.path.stat().st_mtime
                if age > self.stale:
                    self.path.unlink()
            self.fd = os.open(self.path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
            os.write(self.fd, str(os.getpid()).encode())
            return True
        except FileExistsError:
            return False
        except OSError:
            return False

    def release(self):
        if self.fd is not None:
            try:
                os.close(self.fd)
            except OSError:
                pass
            self.fd = None
        try:
            self.path.unlink()
        except OSError:
            pass

    def __enter__(self):
        self.ok = self.acquire()
        return self.ok

    def __exit__(self, *exc):
        if getattr(self, "ok", False):
            self.release()
        return False


def gc(max_bytes: int, protect: set[str]) -> tuple[int, int]:
    root_dirs = [p for p in (cache_dir() / "clut",) if p.is_dir()]
    entries: list[tuple[float, int, Path]] = []
    total = 0
    for base in root_dirs:
        for f in base.rglob("*"):
            if f.is_file():
                st = f.stat()
                total += st.st_size
                entries.append((st.st_mtime, st.st_size, f))
    if total <= max_bytes:
        return 0, 0
    entries.sort()
    removed = freed = 0
    for _mtime, size, f in entries:
        if str(f) in protect:
            continue
        try:
            f.unlink()
        except OSError:
            continue
        removed += 1
        freed += size
        total -= size
        if total <= max_bytes:
            break
    return removed, freed


def gc_tinted(root: Path, max_bytes: int, protect: set[str]) -> tuple[int, int]:
    base = root / TINT_DIR
    if not base.is_dir():
        return 0, 0
    entries: list[tuple[float, int, Path]] = []
    total = 0
    for f in base.rglob("*"):
        if f.is_file():
            st = f.stat()
            total += st.st_size
            entries.append((st.st_mtime, st.st_size, f))
    if total <= max_bytes:
        return 0, 0
    entries.sort()
    removed = freed = 0
    for _mtime, size, f in entries:
        if str(f) in protect:
            continue
        try:
            f.unlink()
        except OSError:
            continue
        removed += 1
        freed += size
        total -= size
        if total <= max_bytes:
            break

    for d in sorted(
        (p for p in base.rglob("*") if p.is_dir()), key=lambda p: -len(p.parts)
    ):
        try:
            d.rmdir()
        except OSError:
            pass
    return removed, freed


def noctalia_msg(args: list[str]) -> bool:
    exe = os.environ.get("NOCWALL_NOCTALIA_BIN", "noctalia")
    if not shutil.which(exe):
        return False
    try:
        proc = subprocess.run(
            [exe, "msg"] + args, capture_output=True, text=True, timeout=20
        )
        return proc.returncode == 0
    except (OSError, subprocess.SubprocessError):
        return False


@dataclass
class TintResult:
    connector: str
    source: Path
    target: Path | None
    action: str
    detail: str = ""


def tint_once(
    root: Path,
    params: Params,
    *,
    dry_run=False,
    force=False,
    st_settings=None,
    state=None,
    log=lambda m: None,
) -> list[TintResult]:
    stg = st_settings or settings.load()
    state = state if state is not None else State()
    results: list[TintResult] = []

    if stg.theme.is_generated:
        log(
            "theme.source is 'wallpaper' (palette generated from the image); "
            "skipping to avoid an oscillation"
        )
        return [TintResult("", Path(), None, "skipped", "generated-palette")]

    expanded = palette.current(stg)
    hexes = palette.tint_colors(expanded)
    if len(hexes) < 4:
        return [
            TintResult(
                "", Path(), None, "skipped", f"palette has only {len(hexes)} colors"
            )
        ]

    key = palette_key(
        hexes, stg.theme.mode, stg.theme.source, stg.theme.selection, params
    )
    log(
        f"palette {stg.theme.source}/{stg.theme.selection} {stg.theme.mode} "
        f"-> key {key} ({len(hexes)} colors)"
    )

    targets = stg.wallpapers.targets()
    if not targets:
        return [TintResult("", Path(), None, "skipped", "no wallpaper set")]

    clut = None
    for connector, current_str in targets.items():
        current = Path(current_str)
        source = state.source_for(connector, current, root)

        if source is None:
            results.append(
                TintResult(
                    connector,
                    current,
                    None,
                    "skipped",
                    "cannot determine the original image",
                )
            )
            continue
        if not source.exists():
            results.append(
                TintResult(connector, source, None, "skipped", "source missing")
            )
            continue
        if source.suffix.lower() in SKIP_SUFFIXES:
            results.append(
                TintResult(
                    connector, source, None, "skipped", f"{source.suffix} not supported"
                )
            )
            continue

        if is_tinted(current, root) and tinted_key(current, root) == key and not force:
            state.remember(connector, source)
            results.append(TintResult(connector, source, current, "already-set"))
            continue

        state.remember(connector, source)
        dst = tinted_path(
            source, root, key, stg.theme.mode, stg.theme.selection, stg.theme.source
        )

        if dst.exists() and not force:
            action = "cache-hit"
        elif dry_run:
            results.append(TintResult(connector, source, dst, "tinted", "dry-run"))
            continue
        else:
            if clut is None:
                clut = ensure_clut(key, hexes, params, root)
            try:
                run_lutgen(source, dst, hexes, params, clut)
            except TintError as e:
                results.append(TintResult(connector, source, None, "skipped", str(e)))
                continue
            action = "tinted"
            record_manifest(root, dst, source)

        if str(dst) == str(current):
            results.append(TintResult(connector, source, dst, "already-set"))
            continue

        if not dry_run:
            args = ["wallpaper-set"] + ([connector] if connector else []) + [str(dst)]
            if not noctalia_msg(args):
                results.append(
                    TintResult(connector, source, dst, action, "wallpaper-set failed")
                )
                continue
        results.append(TintResult(connector, source, dst, action))

    if not dry_run:
        state.save()
    return results
