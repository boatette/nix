from __future__ import annotations

import json
import os
import random
import shutil
import subprocess
from dataclasses import asdict, dataclass
from pathlib import Path

from . import color

SAMPLE = 64


JPEG_HINT = "128x128"

K = 8
KMEANS_ITERS = 12
KMEANS_SEED = 0x5EED


NEUTRAL_CHROMA = 6.0

IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".tif", ".tiff"}


SKIP_SUFFIXES = {".svg"}


class DecodeError(RuntimeError):
    pass


_backend: str | None = None


def backend() -> str:
    global _backend
    if _backend is not None:
        return _backend
    override = os.environ.get("NOCWALL_MAGICK")
    candidates = [override] if override else ["magick", "convert"]
    for cmd in candidates:
        if cmd and shutil.which(cmd):
            _backend = cmd
            return _backend
    raise DecodeError(
        "neither 'magick' nor 'convert' found on PATH; install ImageMagick "
        "or set NOCWALL_MAGICK"
    )


@dataclass
class Features:
    clusters: list[tuple[float, float, float, float]]
    l_star: float
    n_samples: int

    def accents(self, threshold: float = NEUTRAL_CHROMA):
        return [
            c for c in self.clusters if color.chroma((c[0], c[1], c[2])) >= threshold
        ]

    def neutrals(self, threshold: float = NEUTRAL_CHROMA):
        return [
            c for c in self.clusters if color.chroma((c[0], c[1], c[2])) < threshold
        ]

    def to_json(self) -> dict:
        return asdict(self)

    @staticmethod
    def from_json(d: dict) -> "Features":
        return Features(
            clusters=[tuple(c) for c in d["clusters"]],
            l_star=d["l_star"],
            n_samples=d["n_samples"],
        )


def _decode(path: str) -> bytes:
    cmd = [
        backend(),
        "-define",
        f"jpeg:size={JPEG_HINT}",
        f"{path}[0]",
        "-resize",
        f"{SAMPLE}x{SAMPLE}!",
        "-depth",
        "8",
        "-colorspace",
        "sRGB",
        "-alpha",
        "remove",
        "-alpha",
        "off",
        "RGB:-",
    ]
    proc = subprocess.run(cmd, capture_output=True, timeout=60)
    if proc.returncode != 0 or not proc.stdout:
        err = proc.stderr.decode("utf-8", "replace").strip()[:200]
        raise DecodeError(f"{Path(path).name}: {err or 'no output'}")
    return proc.stdout


def _kmeans(points, weights, k=K, iters=KMEANS_ITERS, seed=KMEANS_SEED):
    n = len(points)
    if n == 0:
        return []
    k = min(k, n)
    rng = random.Random(seed)

    centers = [points[rng.randrange(n)]]
    for _ in range(1, k):
        d2 = []
        for p in points:
            best = min(
                (p[0] - c[0]) ** 2 + (p[1] - c[1]) ** 2 + (p[2] - c[2]) ** 2
                for c in centers
            )
            d2.append(best)
        total = sum(d2)
        if total <= 0:
            centers.append(points[rng.randrange(n)])
            continue
        target = rng.random() * total
        acc = 0.0
        for p, w in zip(points, d2):
            acc += w
            if acc >= target:
                centers.append(p)
                break
        else:
            centers.append(points[-1])

    assign = [0] * n
    for _ in range(iters):
        moved = False
        for i, p in enumerate(points):
            best_j, best_d = 0, float("inf")
            for j, c in enumerate(centers):
                d = (p[0] - c[0]) ** 2 + (p[1] - c[1]) ** 2 + (p[2] - c[2]) ** 2
                if d < best_d:
                    best_j, best_d = j, d
            if assign[i] != best_j:
                assign[i] = best_j
                moved = True

        sums = [[0.0, 0.0, 0.0, 0.0] for _ in centers]
        for i, p in enumerate(points):
            s = sums[assign[i]]
            w = weights[i]
            s[0] += p[0] * w
            s[1] += p[1] * w
            s[2] += p[2] * w
            s[3] += w
        for j, s in enumerate(sums):
            if s[3] > 0:
                centers[j] = (s[0] / s[3], s[1] / s[3], s[2] / s[3])
        if not moved:
            break

    mass = [0.0] * len(centers)
    for i in range(n):
        mass[assign[i]] += weights[i]
    total = sum(mass) or 1.0

    out = [
        (centers[j][0], centers[j][1], centers[j][2], mass[j] / total)
        for j in range(len(centers))
        if mass[j] > 0
    ]
    out.sort(key=lambda c: -c[3])
    return out


def extract(path: str) -> Features:
    raw = _decode(path)

    counts: dict[tuple[int, int, int], int] = {}
    for i in range(0, len(raw) - 2, 3):
        key = (raw[i], raw[i + 1], raw[i + 2])
        counts[key] = counts.get(key, 0) + 1

    if not counts:
        raise DecodeError(f"{Path(path).name}: decoded to zero pixels")

    points: list[tuple[float, float, float]] = []
    weights: list[float] = []
    l_sum = 0.0
    n_total = 0
    for (r, g, b), cnt in counts.items():
        lab = color.rgb8_to_lab(r, g, b)
        points.append(lab)
        weights.append(float(cnt))
        l_sum += lab[0] * cnt
        n_total += cnt

    l_star = l_sum / n_total

    clusters = _kmeans(points, weights)
    return Features(clusters=clusters, l_star=l_star, n_samples=n_total)


def cache_path() -> Path:
    env = os.environ.get("XDG_STATE_HOME")
    base = Path(env) if env else Path.home() / ".local/state"
    return base / "nocwall/features.json"


class FeatureCache:
    VERSION = 2

    def __init__(self, path: Path | None = None):
        self.path = path or cache_path()
        self.entries: dict[str, dict] = {}
        self.dirty = False
        self._load()

    def _load(self):
        try:
            with open(self.path, "rb") as fh:
                blob = json.load(fh)
        except (OSError, json.JSONDecodeError):
            return
        if blob.get("version") != self.VERSION:
            return
        self.entries = blob.get("entries", {})

    def _key(self, path: str) -> str | None:
        try:
            st = os.stat(path)
        except OSError:
            return None
        return f"{path}|{st.st_mtime_ns}|{st.st_size}"

    def get(self, path: str) -> Features | None:
        key = self._key(path)
        if key is None:
            return None
        hit = self.entries.get(key)
        if hit is None:
            return None
        try:
            return Features.from_json(hit)
        except (KeyError, TypeError):
            return None

    def put(self, path: str, feats: Features):
        key = self._key(path)
        if key is None:
            return
        self.entries[key] = feats.to_json()
        self.dirty = True

    def save(self):
        if not self.dirty:
            return
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.path.with_suffix(".tmp")
        with open(tmp, "w") as fh:
            json.dump({"version": self.VERSION, "entries": self.entries}, fh)
        os.replace(tmp, self.path)
        self.dirty = False

    def prune(self):
        live = {}
        for key in self.entries:
            path = key.rsplit("|", 2)[0]
            if self._key(path) == key:
                live[key] = self.entries[key]
        if len(live) != len(self.entries):
            self.entries = live
            self.dirty = True


def extract_cached(path: str, cache: FeatureCache | None) -> Features:
    if cache is None:
        return extract(path)
    hit = cache.get(path)
    if hit is not None:
        return hit
    feats = extract(path)
    cache.put(path, feats)
    return feats


def is_image(path: Path) -> bool:
    return path.suffix.lower() in IMAGE_SUFFIXES


def walk_images(root: Path, prune: set[str]) -> list[Path]:
    out: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in prune and not d.startswith(".")]
        for name in filenames:
            p = Path(dirpath) / name
            if is_image(p):
                out.append(p)
    out.sort()
    return out
