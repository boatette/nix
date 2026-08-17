from __future__ import annotations

import os
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from . import journal, settings


@dataclass
class Move:
    src: Path
    dst: Path
    op: str
    mirror_src: Path | None = None
    mirror_dst: Path | None = None


def destination(root: Path, mode: str, folder: str, src: Path) -> Path:
    return root / mode.capitalize() / folder / src.name


def mirror_counterpart(root: Path, mirror: str, path: Path) -> Path | None:
    if not mirror:
        return None
    mroot = root / mirror
    if not mroot.is_dir():
        return None
    try:
        rel = path.relative_to(root)
    except ValueError:
        return None
    mdir = mroot / rel.parent
    if not mdir.is_dir():
        return None
    for cand in mdir.iterdir():
        if cand.is_file() and cand.stem == path.stem:
            return cand
    return None


def _unique(dst: Path) -> Path:
    if not dst.exists():
        return dst
    stem, suffix = dst.stem, dst.suffix
    n = 2
    while True:
        cand = dst.with_name(f"{stem} ({n}){suffix}")
        if not cand.exists():
            return cand
        n += 1


def resolve_collision(src: Path, dst: Path) -> tuple[Path, str]:
    if not dst.exists():
        return dst, "move"
    try:
        if journal.fingerprint(src) == journal.fingerprint(dst):
            return dst, "dedupe"
    except OSError:
        pass
    return _unique(dst), "move-renamed"


def _rename(src: Path, dst: Path):
    dst.parent.mkdir(parents=True, exist_ok=True)
    try:
        os.rename(src, dst)
    except OSError as e:
        if e.errno != 18:
            raise
        tmp = dst.with_suffix(dst.suffix + ".partial")
        shutil.copy2(src, tmp)
        with open(tmp, "rb") as fh:
            os.fsync(fh.fileno())
        os.replace(tmp, dst)
        os.unlink(src)


def plan_moves(decisions, root: Path, mirror: str) -> list[Move]:
    moves: list[Move] = []
    for d in decisions:
        if not d.accepted or not d.best:
            continue
        src = Path(d.path)
        want = destination(root, d.mode, d.best.candidate.folder, src)
        if want == src:
            continue
        dst, op = resolve_collision(src, want)

        msrc = mirror_counterpart(root, mirror, src)
        mdst = None
        if msrc is not None:
            try:
                rel = dst.relative_to(root)
                mdst = _unique(root / mirror / rel.parent / (dst.stem + msrc.suffix))
            except ValueError:
                mdst = None
        moves.append(Move(src, dst, op, msrc, mdst))
    return moves


def apply_moves(
    moves: list[Move], *, dry_run=False, jrnl=None
) -> tuple[str, list[Move]]:
    jrnl = jrnl or journal.Journal()
    batch = journal.batch_id()

    records = []
    for m in moves:
        try:
            fp, size = journal.fingerprint(m.src)
        except OSError:
            continue
        records.append(
            journal.Record(
                batch=batch,
                op=m.op,
                src=str(m.src),
                dst=str(m.dst),
                size=size,
                fp=fp,
                detail=(
                    {"mirror_src": str(m.mirror_src), "mirror_dst": str(m.mirror_dst)}
                    if m.mirror_src and m.mirror_dst
                    else {}
                ),
            )
        )

    if dry_run:
        return batch, []

    jrnl.append(records, sync=True)

    done: list[Move] = []
    for m in moves:
        try:
            if m.op == "dedupe":
                done.append(m)
                continue
            _rename(m.src, m.dst)
            if m.mirror_src and m.mirror_dst:
                try:
                    _rename(m.mirror_src, m.mirror_dst)
                except OSError:
                    pass
            done.append(m)
        except OSError as e:
            jrnl.append(
                [
                    journal.Record(
                        batch=batch,
                        op="error",
                        src=str(m.src),
                        dst=str(m.dst),
                        detail={"error": str(e)},
                    )
                ],
                sync=False,
            )
    return batch, done


def _noctalia_msg(args: list[str]) -> bool:
    exe = os.environ.get("NOCWALL_NOCTALIA_BIN", "noctalia")
    if not shutil.which(exe):
        return False
    try:
        proc = subprocess.run(
            [exe, "msg"] + args, capture_output=True, text=True, timeout=15
        )
        return proc.returncode == 0
    except (OSError, subprocess.SubprocessError):
        return False


def fixup_references(
    moves: list[Move], batch: str, *, jrnl=None, dry_run=False
) -> list[tuple[str, str, str]]:
    jrnl = jrnl or journal.Journal()
    moved = {str(m.src): str(m.dst) for m in moves if m.op != "dedupe"}
    if not moved:
        return []

    try:
        st = settings.load()
    except OSError:
        return []

    changes: list[tuple[str, str, str]] = []
    for connector, path in st.wallpapers.targets().items():
        if path in moved:
            changes.append((connector, path, moved[path]))
    for label, path in (
        ("default", st.wallpapers.default),
        ("last", st.wallpapers.last),
    ):
        if path in moved and not any(c[1] == path for c in changes):
            changes.append(("", path, moved[path]))

    if dry_run or not changes:
        return changes

    for connector, old, new in changes:
        args = ["wallpaper-set"] + ([connector] if connector else []) + [new]
        ok = _noctalia_msg(args)
        jrnl.append(
            [
                journal.Record(
                    batch=batch,
                    op="fixup",
                    src=old,
                    dst=new,
                    detail={"connector": connector, "kind": "wallpaper", "applied": ok},
                )
            ],
            sync=False,
        )
    return changes


def gc_auto_theme_memory(*, dry_run=False) -> int:
    import json as _json

    data_dir = settings.state_home() / "plugins/data/boatette/auto-theme"
    path = data_dir / "dynamic.json"
    if not path.is_file():
        return 0
    try:
        with open(path) as fh:
            mem = _json.load(fh)
    except (OSError, ValueError):
        return 0
    if not isinstance(mem, dict):
        return 0

    live = {k: v for k, v in mem.items() if Path(k).exists()}
    removed = len(mem) - len(live)
    if removed and not dry_run:
        tmp = path.with_suffix(".tmp")
        with open(tmp, "w") as fh:
            _json.dump(live, fh)
        os.replace(tmp, path)
    return removed


def root_guard(path: Path) -> Path:
    home = Path.home()
    if path == home or path.parent == path:
        return path
    try:
        path.relative_to(home)
    except ValueError:
        return Path(path.anchor or "/")
    return home


def undo_batch(batch: str, *, jrnl=None, dry_run=False) -> tuple[int, list[str]]:
    jrnl = jrnl or journal.Journal()
    records = jrnl.records_for(batch)
    if not records:
        return 0, [f"no records for batch {batch}"]

    problems: list[str] = []
    count = 0
    created_dirs: set[Path] = set()

    for rec in reversed(records):
        op = rec.get("op")
        if op not in ("move", "move-renamed"):
            continue
        src, dst = Path(rec["src"]), Path(rec["dst"])

        if not dst.exists():
            problems.append(f"{dst} is gone; cannot restore {src.name}")
            continue
        if src.exists():
            problems.append(f"{src} already exists; refusing to overwrite")
            continue

        try:
            fp, size = journal.fingerprint(dst)
            if rec.get("fp") and fp != rec["fp"]:
                problems.append(f"{dst} changed since the move; skipping")
                continue
        except OSError as e:
            problems.append(f"{dst}: {e}")
            continue

        if dry_run:
            count += 1
            continue

        try:
            _rename(dst, src)
            created_dirs.add(dst.parent)
            count += 1
        except OSError as e:
            problems.append(f"{dst} -> {src}: {e}")
            continue

        detail = rec.get("detail") or {}
        msrc, mdst = detail.get("mirror_src"), detail.get("mirror_dst")
        if msrc and mdst and Path(mdst).exists() and not Path(msrc).exists():
            try:
                _rename(Path(mdst), Path(msrc))
                created_dirs.add(Path(mdst).parent)
            except OSError:
                pass

    if not dry_run:
        for rec in records:
            if rec.get("op") == "fixup" and rec.get("src"):
                connector = (rec.get("detail") or {}).get("connector", "")
                args = (
                    ["wallpaper-set"]
                    + ([connector] if connector else [])
                    + [rec["src"]]
                )
                _noctalia_msg(args)

        for d in sorted(created_dirs, key=lambda p: -len(p.parts)):
            cur = d
            while cur != root_guard(cur):
                try:
                    cur.rmdir()
                except OSError:
                    break
                cur = cur.parent

        jrnl.append(
            [
                journal.Record(
                    batch=journal.batch_id(),
                    op="undo",
                    detail={
                        "target": batch,
                        "reversed": count,
                        "problems": len(problems),
                    },
                )
            ],
            sync=True,
        )

    return count, problems
