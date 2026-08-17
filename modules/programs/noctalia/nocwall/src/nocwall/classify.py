from __future__ import annotations

from dataclasses import dataclass, field

from . import color


DEFAULT_MIN_MARGIN = 0.30
DEFAULT_MAX_DISTANCE = 5.0


DEFAULT_LAMBDA = 0.0


DEFAULT_ALPHA = 0.35


@dataclass(frozen=True)
class Candidate:
    name: str
    folder: str
    source: str
    mode: str
    labs: tuple[tuple[float, float, float], ...] = field(default=())

    @staticmethod
    def from_hexes(name, folder, source, mode, hexes):
        seen: list[tuple[float, float, float]] = []
        for h in hexes:
            lab = color.hex_to_lab(h)
            if lab not in seen:
                seen.append(lab)
        return Candidate(name, folder, source, mode, tuple(seen))


@dataclass
class Score:
    candidate: Candidate
    value: float
    forward: float
    reverse: float


@dataclass
class Decision:
    path: str
    mode: str
    l_star: float
    scores: list[Score]
    accepted: bool
    reason: str
    margin: float = 0.0
    separation: float = 0.0

    @property
    def best(self) -> Score | None:
        return self.scores[0] if self.scores else None

    @property
    def runner_up(self) -> Score | None:
        return self.scores[1] if len(self.scores) > 1 else None

    def top(self, n=3):
        return [(s.candidate.folder, round(s.value, 2)) for s in self.scores[:n]]


def forward_score(clusters, labs, lightness_weight=color.LIGHTNESS_WEIGHT) -> float:
    if not labs or not clusters:
        return float("inf")
    total = 0.0
    for l, a, b, w in clusters:
        p = (l, a, b)
        total += w * min(color.distance(p, q, lightness_weight) for q in labs)
    return total


def reverse_score(clusters, labs, lightness_weight=color.LIGHTNESS_WEIGHT) -> float:
    if not labs or not clusters:
        return float("inf")
    pts = [(l, a, b) for l, a, b, _w in clusters]
    total = sum(min(color.distance(q, p, lightness_weight) for p in pts) for q in labs)
    return total / len(labs)


def separation(
    a: Candidate, b: Candidate, lightness_weight=color.LIGHTNESS_WEIGHT
) -> float:
    if not a.labs or not b.labs:
        return 0.0
    fwd = sum(
        min(color.distance(p, q, lightness_weight) for q in b.labs) for p in a.labs
    ) / len(a.labs)
    rev = sum(
        min(color.distance(q, p, lightness_weight) for p in a.labs) for q in b.labs
    ) / len(b.labs)
    return (fwd + rev) / 2


def classify(
    path: str,
    feats,
    candidates: list[Candidate],
    *,
    mode: str | None = None,
    luma_threshold: float = 45.0,
    min_margin: float = DEFAULT_MIN_MARGIN,
    max_distance: float = DEFAULT_MAX_DISTANCE,
    lam: float = DEFAULT_LAMBDA,
    alpha: float | None = None,
    lightness_weight: float = color.LIGHTNESS_WEIGHT,
) -> Decision:
    resolved_mode = mode or ("light" if feats.l_star > luma_threshold else "dark")
    pool = [c for c in candidates if c.mode == resolved_mode]

    if not pool:
        return Decision(path, resolved_mode, feats.l_star, [], False, "no-candidates")

    scores: list[Score] = []
    for cand in pool:
        fwd = forward_score(feats.clusters, cand.labs, lightness_weight)
        rev = reverse_score(feats.clusters, cand.labs, lightness_weight) if lam else 0.0
        value = (1 - lam) * fwd + lam * rev
        scores.append(Score(cand, value, fwd, rev))
    scores.sort(key=lambda s: s.value)

    best = scores[0]
    second = scores[1] if len(scores) > 1 else None

    if best.value > max_distance:
        return Decision(path, resolved_mode, feats.l_star, scores, False, "no-fit")

    margin = 0.0
    sep = 0.0
    if second is not None and second.value > 0:
        margin = 1 - (best.value / second.value)
        sep = separation(best.candidate, second.candidate, lightness_weight)

        if alpha is not None:
            if (second.value - best.value) < alpha * sep:
                return Decision(
                    path,
                    resolved_mode,
                    feats.l_star,
                    scores,
                    False,
                    "ambiguous",
                    margin,
                    sep,
                )
        elif margin < min_margin:
            return Decision(
                path,
                resolved_mode,
                feats.l_star,
                scores,
                False,
                "ambiguous",
                margin,
                sep,
            )

    return Decision(path, resolved_mode, feats.l_star, scores, True, "ok", margin, sep)


def discover_folders(root, prune: set[str]) -> dict[str, set[str]]:
    from pathlib import Path

    out: dict[str, set[str]] = {"dark": set(), "light": set()}
    for mode, names in (("dark", ("Dark",)), ("light", ("Light",))):
        for top in names:
            d = Path(root) / top
            if not d.is_dir():
                continue
            for child in d.iterdir():
                if (
                    child.is_dir()
                    and child.name not in prune
                    and not child.name.startswith((".", "_"))
                ):
                    out[mode].add(child.name)
    return out


def build_candidates(
    folders: dict[str, set[str]],
    resolve,
    dynamic_names: set[str],
) -> tuple[list[Candidate], list[tuple[str, str]]]:
    cands: list[Candidate] = []
    unresolved: list[tuple[str, str]] = []
    for mode, names in folders.items():
        for folder in sorted(names):
            if folder.lower() in dynamic_names:
                continue
            try:
                name, source, hexes = resolve(folder, mode)
            except LookupError:
                unresolved.append((folder, mode))
                continue
            if not hexes:
                unresolved.append((folder, mode))
                continue
            cands.append(Candidate.from_hexes(name, folder, source, mode, hexes))
    return cands, unresolved
