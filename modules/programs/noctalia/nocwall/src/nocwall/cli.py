from __future__ import annotations

import argparse
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from . import classify, color, features, palette, settings
from . import journal as journal_mod

DEFAULT_ROOT = Path.home() / "Pictures/Wallpapers"


DEFAULT_PRUNE = {"_optimised", "_optimized", "_tinted"}
DYNAMIC_NAMES = {"dynamic"}


def _root(args) -> Path:
    return Path(args.root).expanduser() if args.root else DEFAULT_ROOT


def _prune(args) -> set[str]:
    p = set(DEFAULT_PRUNE)
    for extra in args.prune or []:
        p.add(extra)
    return p


def _resolver():
    builtins = {palette.norm(k): (k, v) for k, v in palette.builtins().items()}
    community = palette.load_community()
    custom = palette.load_custom()

    def resolve(folder: str, mode: str):
        key = palette.norm(folder)
        for source, table in (
            ("builtin", builtins),
            ("community", community),
            ("custom", custom),
        ):
            if key in table:
                name, data = table[key]
                seed = data.get(mode) or (data if "mPrimary" in data else None)
                if seed is None:
                    continue
                return name, source, _seed_hexes(seed)
        raise LookupError(folder)

    return resolve


def _seed_hexes(seed: dict) -> list[str]:
    out: list[str] = []

    def add(v):
        if isinstance(v, str) and v.startswith("#"):
            out.append(v)

    for key in (
        "mSurface",
        "mSurfaceVariant",
        "mOnSurface",
        "mOnSurfaceVariant",
        "mShadow",
        "mOutline",
    ):
        add(seed.get(key))

    for key in ("mPrimary", "mSecondary", "mTertiary", "mError"):
        add(seed.get(key))

    term = seed.get("terminal") or {}
    for word in ("normal", "bright"):
        for v in (term.get(word) or {}).values():
            add(v)
    for key in ("background", "foreground"):
        add(term.get(key))

    return out


def _load_candidates(args):
    root = _root(args)
    prune = _prune(args)
    folders = classify.discover_folders(root, prune)
    cands, unresolved = classify.build_candidates(folders, _resolver(), DYNAMIC_NAMES)
    if unresolved and not args.quiet:
        for folder, mode in unresolved:
            print(
                f"warning: {mode}/{folder} resolves to no known palette",
                file=sys.stderr,
            )
    return cands


def _extract_many(paths, cache, jobs, quiet=False):
    results: dict[str, features.Features] = {}
    errors: list[str] = []

    def work(p):
        try:
            return str(p), features.extract_cached(str(p), cache), None
        except features.DecodeError as e:
            return str(p), None, str(e)

    with ThreadPoolExecutor(max_workers=jobs) as ex:
        for path, feats, err in ex.map(work, paths):
            if err:
                errors.append(err)
            else:
                results[path] = feats

    if errors and not quiet:
        print(f"warning: {len(errors)} file(s) failed to decode:", file=sys.stderr)
        for e in errors[:5]:
            print(f"  {e}", file=sys.stderr)
        if len(errors) > 5:
            print(f"  ... and {len(errors) - 5} more", file=sys.stderr)
    return results


def tint_defaults():
    from . import tint as tintmod

    return (
        tintmod.DEFAULT_ALGORITHM,
        tintmod.DEFAULT_POWER,
        tintmod.DEFAULT_NEAREST,
        tintmod.DEFAULT_LUM,
    )


def _pct(values, q):
    if not values:
        return float("nan")
    s = sorted(values)
    return s[min(len(s) - 1, int(q * len(s)))]


def cmd_palette(args):
    if args.what == "list":
        print("builtin:")
        for name in palette.builtins():
            print(f"  {name}")
        com = palette.load_community()
        print("community:" if com else "community: (none downloaded)")
        for _k, (name, _d) in sorted(com.items()):
            print(f"  {name}")
        cus = palette.load_custom()
        print("custom:" if cus else "custom: (none)")
        for _k, (name, _d) in sorted(cus.items()):
            print(f"  {name}")
        return 0

    if args.what == "harvest":
        data = palette.builtins()
        out = json.dumps(data, indent=1, ensure_ascii=False)
        if args.out:
            Path(args.out).write_text(out + "\n")
            print(f"wrote {args.out}: {len(data)} palettes", file=sys.stderr)
        else:
            print(out)
        return 0

    if args.what == "current":
        st = settings.load()
        expanded = palette.current(st)
        tints = palette.tint_colors(expanded)
        print(f"source     {st.theme.source}")
        print(f"selection  {st.theme.selection}")
        print(f"mode       {st.theme.mode}")
        print(f"generated  {st.theme.is_generated}")
        print(f"tint set   {len(tints)} colors")
        for t in tints:
            print(f"  {t}")
        return 0

    if args.what == "show":
        if not args.name:
            print("palette show needs a NAME", file=sys.stderr)
            return 2
        source, _, name = args.name.partition("/")
        if not name:
            source, name = "builtin", source
        seed = palette.seed_for(source, name, args.mode)
        print(json.dumps(seed, indent=1, ensure_ascii=False))
        return 0

    return 2


def cmd_probe(args):
    cands = _load_candidates(args)
    cache = None if args.no_cache else features.FeatureCache()
    for path in args.paths:
        try:
            feats = features.extract_cached(path, cache)
        except features.DecodeError as e:
            print(f"{path}: DECODE FAILED: {e}")
            continue
        d = classify.classify(
            path,
            feats,
            cands,
            mode=args.mode,
            luma_threshold=args.luma_threshold,
            min_margin=args.min_margin,
            max_distance=args.max_distance,
            lam=args.lam,
            alpha=args.alpha,
        )
        print(f"\n{path}")
        print(f"  L* {feats.l_star:.1f} -> {d.mode}   samples {feats.n_samples}")
        print("  clusters (L* a* b* weight):")
        for l, a, b, w in feats.clusters:
            print(
                f"    {l:6.1f} {a:7.1f} {b:7.1f}  {w:5.1%}  "
                f"{color.rgb8_to_hex(*_lab_to_rgb8(l, a, b))}"
            )
        print("  scores:")
        for s in d.scores[:6]:
            print(
                f"    {s.candidate.folder:14s} {s.value:7.2f}"
                + (f"  (fwd {s.forward:.2f} rev {s.reverse:.2f})" if args.lam else "")
            )
        verdict = d.best.candidate.folder if d.accepted else f"ABSTAIN ({d.reason})"
        print(f"  margin {d.margin:.3f}  separation {d.separation:.1f}  -> {verdict}")
    if cache:
        cache.save()
    return 0


def _lab_to_rgb8(l, a, b):
    fy = (l + 16) / 116
    fx = fy + a / 500
    fz = fy - b / 200

    def inv(t):
        return t**3 if t**3 > 0.008856 else (116 * t - 16) / 903.3

    x = inv(fx) * 0.95047
    y = inv(fy) * 1.0
    z = inv(fz) * 1.08883
    r = 3.2404542 * x - 1.5371385 * y - 0.4985314 * z
    g = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z
    bb = 0.0556434 * x - 0.2040259 * y + 1.0572252 * z
    out = []
    for c in (r, g, bb):
        c = color.linear_to_srgb(max(0.0, min(1.0, c)))
        out.append(int(round(max(0.0, min(1.0, c)) * 255)))
    return tuple(out)


def cmd_eval(args):
    root = _root(args)
    prune = _prune(args)
    cands = _load_candidates(args)
    if not cands:
        print("no candidate palettes found", file=sys.stderr)
        return 1

    known = {(c.folder, c.mode) for c in cands}
    labelled: list[tuple[Path, str, str]] = []
    for mode, top in (("dark", "Dark"), ("light", "Light")):
        base = root / top
        if not base.is_dir():
            continue
        for folder in sorted(p for p in base.iterdir() if p.is_dir()):
            if folder.name in prune or (folder.name, mode) not in known:
                continue
            if args.exclude_class and f"{top}/{folder.name}" in args.exclude_class:
                continue
            for img in sorted(folder.iterdir()):
                if img.is_file() and features.is_image(img):
                    labelled.append((img, folder.name, mode))

    if args.limit_per_class:
        import random as _r

        rng = _r.Random(args.seed)
        by: dict[tuple[str, str], list] = {}
        for item in labelled:
            by.setdefault((item[1], item[2]), []).append(item)
        labelled = []
        for key, items in by.items():
            rng.shuffle(items)
            labelled.extend(items[: args.limit_per_class])

    if not labelled:
        print("no labelled images found", file=sys.stderr)
        return 1

    if not args.quiet:
        print(
            f"{len(labelled)} labelled images, {len(cands)} candidates "
            f"({len(known)} folder/mode pairs)",
            file=sys.stderr,
        )

    cache = None if args.no_cache else features.FeatureCache()
    feats_by_path = _extract_many(
        [p for p, _, _ in labelled], cache, args.jobs, args.quiet
    )
    if cache:
        cache.save()

    per_class: dict[str, dict] = {}
    confusion: dict[str, dict[str, int]] = {}
    good_fits: list[float] = []
    mode_right = mode_total = 0
    t1 = t2 = t3 = total = 0

    for img, folder, mode in labelled:
        feats = feats_by_path.get(str(img))
        if feats is None:
            continue

        d = classify.classify(
            str(img),
            feats,
            cands,
            mode=(None if args.mode_policy == "luma" else mode),
            luma_threshold=args.luma_threshold,
            min_margin=args.min_margin,
            max_distance=args.max_distance,
            lam=args.lam,
            alpha=args.alpha,
        )
        total += 1
        mode_total += 1
        if d.mode == mode:
            mode_right += 1

        ranked = [s.candidate.folder for s in d.scores]
        cls = per_class.setdefault(
            folder,
            {"n": 0, "t1": 0, "t2": 0, "t3": 0, "accepted": 0, "accepted_right": 0},
        )
        cls["n"] += 1

        if folder in ranked:
            idx = ranked.index(folder)
            if idx == 0:
                t1 += 1
                cls["t1"] += 1
            if idx <= 1:
                t2 += 1
                cls["t2"] += 1
            if idx <= 2:
                t3 += 1
                cls["t3"] += 1

        if ranked:
            confusion.setdefault(folder, {})
            confusion[folder][ranked[0]] = confusion[folder].get(ranked[0], 0) + 1

        if ranked and ranked[0] == folder and d.best:
            good_fits.append(d.best.value)

        if d.accepted:
            cls["accepted"] += 1
            if ranked and ranked[0] == folder:
                cls["accepted_right"] += 1

    if total == 0:
        print("no images could be scored", file=sys.stderr)
        return 1

    print(
        f"\nmetric lam={args.lam} alpha={args.alpha} "
        f"min_margin={args.min_margin} max_distance={args.max_distance} "
        f"mode_policy={args.mode_policy}"
    )
    print(
        f"\n{'class':16s} {'n':>4s} {'top1':>10s} {'top2':>10s} {'top3':>10s} "
        f"{'accepted':>10s} {'acc.prec':>9s}"
    )
    print("-" * 76)
    for folder in sorted(per_class):
        c = per_class[folder]
        n = c["n"]
        prec = (
            (100 * c["accepted_right"] / c["accepted"])
            if c["accepted"]
            else float("nan")
        )
        print(
            f"{folder:16s} {n:4d} "
            f"{c['t1']:4d} {100 * c['t1'] / n:5.0f}% "
            f"{c['t2']:4d} {100 * c['t2'] / n:5.0f}% "
            f"{c['t3']:4d} {100 * c['t3'] / n:5.0f}% "
            f"{c['accepted']:4d} {100 * c['accepted'] / n:5.0f}% "
            f"{prec:8.0f}%"
        )
    n_acc = sum(c["accepted"] for c in per_class.values())
    n_acc_right = sum(c["accepted_right"] for c in per_class.values())
    acc_prec = (100 * n_acc_right / n_acc) if n_acc else float("nan")

    print("-" * 76)
    print(
        f"{'OVERALL':16s} {total:4d} "
        f"{t1:4d} {100 * t1 / total:5.0f}% "
        f"{t2:4d} {100 * t2 / total:5.0f}% "
        f"{t3:4d} {100 * t3 / total:5.0f}% "
        f"{n_acc:4d} {100 * n_acc / total:5.0f}% "
        f"{acc_prec:8.0f}%"
    )
    print(
        f"\nmode accuracy (L* vs {args.luma_threshold}): "
        f"{mode_right}/{mode_total} = {100 * mode_right / mode_total:.0f}%"
    )

    print(
        f"gates: coverage {n_acc}/{total} = {100 * n_acc / total:.0f}%, "
        f"precision {n_acc_right}/{n_acc} = {acc_prec:.0f}%"
        if n_acc
        else "gates: nothing accepted"
    )

    if good_fits:
        print(
            "\nknown-good-fit distribution (correctly ranked only) -- "
            "max_distance should be a percentile of this:"
        )
        header = "  " + "".join(
            f"{f'p{int(q * 100)}':>8s}" for q in (0.10, 0.25, 0.50, 0.75, 0.90, 0.95)
        )
        print(header + f"{'max':>8s}")
        print(
            "  "
            + "".join(
                f"{_pct(good_fits, q):8.1f}"
                for q in (0.10, 0.25, 0.50, 0.75, 0.90, 0.95)
            )
            + f"{max(good_fits):8.1f}"
        )

    if args.confusion:
        print("\nconfusion (row = truth, col = top-1 pick):")
        cols = sorted({c for row in confusion.values() for c in row})
        print("  " + " " * 16 + "".join(f"{c[:8]:>9s}" for c in cols))
        for folder in sorted(confusion):
            row = confusion[folder]
            print(f"  {folder:16s}" + "".join(f"{row.get(c, 0):9d}" for c in cols))

    if args.out:
        Path(args.out).write_text(
            json.dumps(
                {
                    "params": {
                        "lam": args.lam,
                        "alpha": args.alpha,
                        "min_margin": args.min_margin,
                        "max_distance": args.max_distance,
                        "mode_policy": args.mode_policy,
                        "luma_threshold": args.luma_threshold,
                    },
                    "overall": {
                        "n": total,
                        "top1": t1,
                        "top2": t2,
                        "top3": t3,
                        "mode_right": mode_right,
                    },
                    "per_class": per_class,
                    "confusion": confusion,
                    "good_fit_percentiles": {
                        f"p{int(q * 100)}": _pct(good_fits, q)
                        for q in (0.10, 0.25, 0.50, 0.75, 0.90, 0.95)
                    },
                },
                indent=1,
            )
        )
        print(f"\nwrote {args.out}", file=sys.stderr)

    return 0


def cmd_plan(args):
    root = _root(args)
    prune = _prune(args)
    cands = _load_candidates(args)
    if not cands:
        print("no candidate palettes found", file=sys.stderr)
        return 1

    scope = Path(args.dir).expanduser() if args.dir else root / "Dynamic"
    if not scope.is_dir():
        print(f"not a directory: {scope}", file=sys.stderr)
        return 1

    paths = features.walk_images(scope, prune)
    if args.limit:
        paths = paths[: args.limit]
    if not paths:
        print(f"no images under {scope}", file=sys.stderr)
        return 0

    if not args.quiet:
        print(f"{len(paths)} images under {scope}", file=sys.stderr)

    cache = None if args.no_cache else features.FeatureCache()
    feats_by_path = _extract_many(paths, cache, args.jobs, args.quiet)
    if cache:
        cache.save()

    decisions = []
    for p in paths:
        feats = feats_by_path.get(str(p))
        if feats is None:
            continue
        decisions.append(
            classify.classify(
                str(p),
                feats,
                cands,
                mode=args.mode,
                luma_threshold=args.luma_threshold,
                min_margin=args.min_margin,
                max_distance=args.max_distance,
                lam=args.lam,
                alpha=args.alpha,
            )
        )

    if args.tsv:
        print("action\tmode\tdest\tscore\tmargin\tl_star\ttop3\tpath")
        for d in decisions:
            action = "move" if d.accepted else f"skip:{d.reason}"
            dest = d.best.candidate.folder if (d.accepted and d.best) else ""
            score = f"{d.best.value:.2f}" if d.best else ""
            print(
                f"{action}\t{d.mode}\t{dest}\t{score}\t{d.margin:.3f}\t"
                f"{d.l_star:.1f}\t{d.top(3)}\t{d.path}"
            )
        return 0

    moved: dict[tuple[str, str], int] = {}
    reasons: dict[str, int] = {}
    for d in decisions:
        if d.accepted and d.best:
            key = (d.mode.capitalize(), d.best.candidate.folder)
            moved[key] = moved.get(key, 0) + 1
        else:
            reasons[d.reason] = reasons.get(d.reason, 0) + 1

    n = len(decisions)
    n_move = sum(moved.values())
    print(
        f"\nwould file {n_move}/{n} ({100 * n_move / n:.0f}%), "
        f"leaving {n - n_move} in place\n"
    )
    if moved:
        print(f"{'destination':28s} {'files':>6s}")
        print("-" * 36)
        for (mode, folder), count in sorted(moved.items(), key=lambda kv: -kv[1]):
            print(f"{mode + '/' + folder:28s} {count:6d}")
        print("-" * 36)
        print(f"{'TOTAL':28s} {n_move:6d}")
    if reasons:
        print(f"\n{'left in place':28s} {'files':>6s}")
        print("-" * 36)
        for reason, count in sorted(reasons.items(), key=lambda kv: -kv[1]):
            print(f"{reason:28s} {count:6d}")
    print("\nThis is a dry run; nothing was moved. `nocwall apply` performs the moves.")
    return 0


def _decide_all(args, scope, cands, prune):
    paths = features.walk_images(scope, prune)
    if args.limit:
        paths = paths[: args.limit]
    if not paths:
        return []

    if getattr(args, "settle_secs", 0):
        import time

        cutoff = time.time() - args.settle_secs
        fresh = [p for p in paths if p.stat().st_mtime > cutoff]
        if fresh and not args.quiet:
            print(
                f"skipping {len(fresh)} file(s) modified in the last "
                f"{args.settle_secs}s",
                file=sys.stderr,
            )
        paths = [p for p in paths if p.stat().st_mtime <= cutoff]

    cache = None if args.no_cache else features.FeatureCache()
    feats_by_path = _extract_many(paths, cache, args.jobs, args.quiet)
    if cache:
        cache.save()

    out = []
    for p in paths:
        f = feats_by_path.get(str(p))
        if f is None:
            continue
        out.append(
            classify.classify(
                str(p),
                f,
                cands,
                mode=args.mode,
                luma_threshold=args.luma_threshold,
                min_margin=args.min_margin,
                max_distance=args.max_distance,
                lam=args.lam,
                alpha=args.alpha,
            )
        )
    return out


def cmd_apply(args):
    from . import sort as sortmod

    root = _root(args)
    prune = _prune(args)
    cands = _load_candidates(args)
    if not cands:
        print("no candidate palettes found", file=sys.stderr)
        return 1

    scope = Path(args.dir).expanduser() if args.dir else root / "Dynamic"
    if not scope.is_dir():
        print(f"not a directory: {scope}", file=sys.stderr)
        return 1

    if scope.resolve() == root.resolve() and not args.i_mean_it:
        print(
            f"refusing to sort the whole tree ({root}) without --i-mean-it;\n"
            f"the default scope is {root / 'Dynamic'}",
            file=sys.stderr,
        )
        return 2

    decisions = _decide_all(args, scope, cands, prune)
    if not decisions:
        print("nothing to do", file=sys.stderr)
        return 0

    moves = sortmod.plan_moves(decisions, root, args.mirror_dir)
    if not moves:
        print(f"0 of {len(decisions)} images passed both gates; nothing to move")
        return 0

    if args.dry_run:
        for m in moves:
            print(f"{m.op:12s} {m.src}  ->  {m.dst}")
        print(f"\n{len(moves)} move(s); dry run, nothing written")
        return 0

    batch, done = sortmod.apply_moves(moves)
    n_dedupe = sum(1 for m in done if m.op == "dedupe")
    n_renamed = sum(1 for m in done if m.op == "move-renamed")
    print(
        f"batch {batch}: {len(done)} of {len(moves)} applied"
        + (f", {n_dedupe} duplicate(s) left in place" if n_dedupe else "")
        + (f", {n_renamed} renamed to avoid a collision" if n_renamed else "")
    )

    if args.fixup_refs:
        changes = sortmod.fixup_references(done, batch)
        for connector, old, new in changes:
            where = connector or "all outputs"
            print(f"repointed {where}: {Path(old).name} -> {new}")
        removed = sortmod.gc_auto_theme_memory()
        if removed:
            print(f"dropped {removed} dead key(s) from auto-theme's dynamic.json")

    print(f"\nUndo with: nocwall undo --batch {batch}")
    if args.mirror_dir:
        print(
            f"The {args.mirror_dir}/ mirror is stale for any file that had no "
            f"counterpart; re-run optimize-wallpapers.sh to refresh it."
        )
    return 0


def cmd_undo(args):
    from . import sort as sortmod

    jrnl = journal_mod.Journal()
    batch = args.batch
    if not batch:
        batches = jrnl.batches()
        if not batches:
            print("no batches to undo", file=sys.stderr)
            return 1
        batch = batches[-1]

    count, problems = sortmod.undo_batch(batch, jrnl=jrnl, dry_run=args.dry_run)
    verb = "would reverse" if args.dry_run else "reversed"
    print(f"{verb} {count} move(s) from batch {batch}")
    for p in problems:
        print(f"  problem: {p}", file=sys.stderr)
    return 0 if not problems else 1


def cmd_journal(args):
    jrnl = journal_mod.Journal()
    batches = jrnl.batches()
    if not batches:
        print("journal is empty")
        return 0
    for b in batches:
        recs = jrnl.records_for(b)
        ops: dict[str, int] = {}
        for r in recs:
            ops[r["op"]] = ops.get(r["op"], 0) + 1
        summary = ", ".join(f"{k}={v}" for k, v in sorted(ops.items()))
        print(f"{b}  {summary}")
    return 0


def cmd_tint(args):
    from . import tint as tintmod

    root = _root(args)
    params = tintmod.Params(
        algorithm=args.algorithm,
        preserve=not args.no_preserve,
        power=args.power,
        nearest=args.nearest,
        lum=args.lum,
    )

    if args.what == "gc":
        stg = settings.load()
        protect = {p for p in stg.wallpapers.targets().values()}
        n1, b1 = tintmod.gc_tinted(root, args.max_bytes, protect)
        n2, b2 = tintmod.gc(args.max_bytes, set())
        print(f"evicted {n1 + n2} file(s), freed {(b1 + b2) / 1e6:.1f} MB")
        return 0

    if not tintmod.have_lutgen():
        print(
            f"error: {tintmod.lutgen_bin()} not found on PATH.\n"
            f"  nix shell nixpkgs#lutgen      (to try it)\n"
            f"  or add lutgen to home.packages (to keep it)",
            file=sys.stderr,
        )
        return 1

    state = tintmod.State()

    if args.reason == "wallpaper" and not args.now:
        token = f"wallpaper|{args.connector or ''}|{args.path or ''}"
        if state.should_dedupe(token):
            return 0
        state.mark_pending(args.connector or "", args.path or "")
        state.save()
        if not args.quiet:
            print(
                "wallpaper change recorded; waiting for the palette to settle",
                file=sys.stderr,
            )
        return 0

    with tintmod.Lock() as got:
        if not got:
            if not args.quiet:
                print("another tint is already running; nothing to do", file=sys.stderr)
            return 0

        state.take_pending()
        results = tintmod.tint_once(
            root,
            params,
            dry_run=args.dry_run,
            force=args.force,
            state=state,
            log=(lambda m: None)
            if args.quiet
            else (lambda m: print(m, file=sys.stderr)),
        )

    for r in results:
        where = r.connector or "all outputs"
        if r.action == "skipped":
            print(f"{where}: skipped ({r.detail})")
        elif r.action == "already-set":
            print(f"{where}: already showing the tinted version")
        else:
            note = f" [{r.detail}]" if r.detail else ""
            print(f"{where}: {r.action}{note}\n  {r.source.name} -> {r.target}")
    return 0


def build_parser():
    p = argparse.ArgumentParser(
        prog="nocwall",
        description="Sort wallpapers by palette and recolor them to the active scheme.",
    )
    p.add_argument("--root", help=f"wallpaper tree (default {DEFAULT_ROOT})")
    p.add_argument(
        "--prune", action="append", help="extra directory name to skip (repeatable)"
    )
    p.add_argument("--jobs", type=int, default=min(8, (os.cpu_count() or 4)))
    p.add_argument("--no-cache", action="store_true", help="ignore the feature cache")
    p.add_argument("-q", "--quiet", action="store_true")

    sub = p.add_subparsers(dest="cmd", required=True)

    def add_tuning(sp):
        sp.add_argument(
            "--luma-threshold",
            type=float,
            default=45.0,
            help="CIELAB L* above which an image is 'light' (default 45)",
        )
        sp.add_argument("--min-margin", type=float, default=classify.DEFAULT_MIN_MARGIN)
        sp.add_argument(
            "--max-distance", type=float, default=classify.DEFAULT_MAX_DISTANCE
        )
        sp.add_argument(
            "--lam",
            type=float,
            default=classify.DEFAULT_LAMBDA,
            help="weight of the reverse coverage term (0 = one-directional)",
        )
        sp.add_argument(
            "--alpha",
            type=float,
            default=None,
            help="separation-normalized ambiguity gate; replaces --min-margin",
        )
        sp.add_argument(
            "--mode",
            choices=("dark", "light"),
            default=None,
            help="force light/dark instead of deriving it from L*",
        )

    sp = sub.add_parser("palette", help="inspect palettes")
    sp.add_argument("what", choices=("current", "show", "list", "harvest"))
    sp.add_argument("name", nargs="?", help="[source/]name for `show`")
    sp.add_argument("--mode", choices=("dark", "light"), default="dark")
    sp.add_argument("--out", help="write to a file instead of stdout")
    sp.set_defaults(func=cmd_palette)

    sp = sub.add_parser("probe", help="dump features and scores for specific files")
    sp.add_argument("paths", nargs="+")
    add_tuning(sp)
    sp.set_defaults(func=cmd_probe)

    sp = sub.add_parser("eval", help="measure accuracy against the hand-sorted tree")
    add_tuning(sp)
    sp.add_argument("--confusion", action="store_true")
    sp.add_argument(
        "--exclude-class", action="append", help="e.g. Dark/Rose-Pine (repeatable)"
    )
    sp.add_argument("--limit-per-class", type=int, default=0)
    sp.add_argument("--seed", type=int, default=7)
    sp.add_argument(
        "--mode-policy",
        choices=("luma", "truth"),
        default="luma",
        help="'truth' uses the real mode, isolating palette accuracy",
    )
    sp.add_argument("--out", help="write results as JSON")
    sp.set_defaults(func=cmd_eval)

    sp = sub.add_parser("plan", help="show what sorting would do (dry run)")
    sp.add_argument("dir", nargs="?", help="directory to sort (default <root>/Dynamic)")
    add_tuning(sp)
    sp.add_argument(
        "--tsv", action="store_true", help="machine-readable per-file output"
    )
    sp.add_argument("--limit", type=int, default=0)
    sp.set_defaults(func=cmd_plan)

    sp = sub.add_parser("apply", help="perform the moves a plan describes")
    sp.add_argument("dir", nargs="?", help="directory to sort (default <root>/Dynamic)")
    add_tuning(sp)
    sp.add_argument("--limit", type=int, default=0)
    sp.add_argument(
        "--dry-run",
        action="store_true",
        help="list the exact renames without performing them",
    )
    sp.add_argument(
        "--settle-secs",
        type=int,
        default=10,
        help="skip files modified this recently (in-flight downloads)",
    )
    sp.add_argument(
        "--mirror-dir",
        default=".optimised",
        help="derived mirror tree to keep in step ('' to disable); "
        "matches walls-optimise.sh's default output directory",
    )
    sp.add_argument(
        "--no-fixup-refs",
        dest="fixup_refs",
        action="store_false",
        help="do not repoint wallpaper settings at moved files",
    )
    sp.add_argument(
        "--i-mean-it",
        action="store_true",
        help="required to sort the whole tree rather than Dynamic/",
    )
    sp.set_defaults(func=cmd_apply, fixup_refs=True)

    sp = sub.add_parser("undo", help="reverse a batch of moves")
    sp.add_argument("--batch", help="batch id (default: the most recent)")
    sp.add_argument("--dry-run", action="store_true")
    sp.set_defaults(func=cmd_undo)

    sp = sub.add_parser("journal", help="list recorded batches")
    sp.set_defaults(func=cmd_journal)

    sp = sub.add_parser("tint", help="recolor the wallpaper to the active palette")
    sp.add_argument("what", nargs="?", choices=("run", "gc"), default="run")
    sp.add_argument(
        "--reason",
        choices=("colors", "wallpaper", "manual"),
        default="manual",
        help="which hook fired; 'wallpaper' defers to the settle window",
    )
    sp.add_argument("--connector", default="", help="output name from the hook")
    sp.add_argument("--path", default="", help="wallpaper path from the hook")
    sp.add_argument(
        "--now", action="store_true", help="act immediately even for --reason wallpaper"
    )
    sp.add_argument("--dry-run", action="store_true")
    sp.add_argument("--force", action="store_true", help="re-tint even on a cache hit")
    sp.add_argument(
        "--algorithm",
        default=tint_defaults()[0],
        choices=(
            "shepards-method",
            "gaussian-rbf",
            "nearest-neighbor",
            "gaussian-sampling",
        ),
    )
    sp.add_argument(
        "--no-preserve",
        action="store_true",
        help="do not preserve the original luminosity (rarely wanted)",
    )
    sp.add_argument("--power", type=float, default=tint_defaults()[1])
    sp.add_argument("--nearest", type=int, default=tint_defaults()[2])
    sp.add_argument("--lum", type=float, default=tint_defaults()[3])
    sp.add_argument(
        "--max-bytes",
        type=int,
        default=4_000_000_000,
        help="cache budget for `tint gc`",
    )
    sp.set_defaults(func=cmd_tint)

    return p


def main(argv=None):
    args = build_parser().parse_args(argv)
    try:
        return args.func(args)
    except KeyboardInterrupt:
        return 130
    except (features.DecodeError, LookupError, RuntimeError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
