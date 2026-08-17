import tempfile
import unicodedata
import unittest
from pathlib import Path

from nocwall import tint


def _norm(s: str) -> str:
    d = unicodedata.normalize("NFKD", s)
    return "".join(
        c for c in d if not unicodedata.combining(c) and c.isascii() and c.isalnum()
    ).lower()


DARK_NAMES = {"dark"}
LIGHT_NAMES = {"light"}
DYNAMIC_NAMES = {"dynamic"}


def auto_theme_map(root: Path, path: Path):
    try:
        rel = path.relative_to(root)
    except ValueError:
        return None, None
    segs = list(rel.parts[:-1])
    mode_idx = mode = None
    for i, seg in enumerate(segs):
        k = _norm(seg)
        if k in DARK_NAMES:
            mode_idx, mode = i, "dark"
            break
        if k in LIGHT_NAMES:
            mode_idx, mode = i, "light"
            break
    if mode_idx is not None:
        if mode_idx + 1 < len(segs):
            folder = segs[mode_idx + 1]
        elif mode_idx > 0:
            folder = segs[mode_idx - 1]
        else:
            folder = None
    else:
        folder = segs[-1] if segs else None
    return mode, folder


def auto_theme_is_dynamic(folder) -> bool:
    return folder is not None and _norm(folder) in DYNAMIC_NAMES


ROOT = Path("/home/u/Pictures/Wallpapers")


class TestAutoThemeAgreement(unittest.TestCase):
    CASES = [
        ("Dynamic/portal.png", "dark", "Nord", "builtin"),
        ("Dynamic/portal.png", "light", "Nord", "builtin"),
        ("Dark/Rose-Pine/x.png", "dark", "Nord", "builtin"),
        ("Dark/Monochrome/y.png", "dark", "Gruvbox", "builtin"),
        ("Light/Nord/z.png", "light", "Monochrome", "community"),
        ("Dynamic/a.png", "dark", "Rosé Pine", "builtin"),
        ("_optimised/Dynamic/b.png", "dark", "Tokyo-Night", "builtin"),
    ]

    def test_tinted_path_resolves_to_the_active_palette(self):
        for rel, mode, selection, source in self.CASES:
            src = ROOT / rel
            dst = tint.tinted_path(src, ROOT, "key123", mode, selection, source)
            got_mode, got_folder = auto_theme_map(ROOT, dst)

            self.assertEqual(got_mode, mode, f"{rel} -> {dst}")
            self.assertFalse(
                auto_theme_is_dynamic(got_folder),
                f"{rel} tinted to {selection} resolved as DYNAMIC via {dst} -- "
                "this is the bug that reverted the user's theme",
            )
            self.assertEqual(
                _norm(got_folder),
                _norm(selection),
                f"{rel} tinted to {selection} resolves to {got_folder!r}",
            )

    def test_dynamic_source_never_yields_a_dynamic_path(self):
        dst = tint.tinted_path(
            ROOT / "Dynamic/Neon.png", ROOT, "k", "dark", "Eldritch", "builtin"
        )
        self.assertNotIn("Dynamic", dst.parts)
        _mode, folder = auto_theme_map(ROOT, dst)
        self.assertFalse(auto_theme_is_dynamic(folder))

    def test_original_folder_does_not_leak_into_the_path(self):
        dst = tint.tinted_path(
            ROOT / "Dark/Rose-Pine/x.png", ROOT, "k", "dark", "Nord", "builtin"
        )
        self.assertNotIn("Rose-Pine", dst.parts)
        self.assertIn("Nord", dst.parts)


class TestPathLayout(unittest.TestCase):
    def test_hidden_directory(self):
        self.assertTrue(tint.TINT_DIR.startswith("."))
        dst = tint.tinted_path(
            ROOT / "Dynamic/a.png", ROOT, "k", "dark", "Nord", "builtin"
        )
        self.assertEqual(dst.relative_to(ROOT).parts[0], ".tinted")

    def test_always_png(self):
        for name in ("a.jpg", "b.webp", "c.jpeg", "d.png"):
            dst = tint.tinted_path(
                ROOT / "Dynamic" / name, ROOT, "k", "dark", "Nord", "builtin"
            )
            self.assertEqual(dst.suffix, ".png")

    def test_same_stem_from_different_folders_does_not_collide(self):
        a = tint.tinted_path(
            ROOT / "Dynamic/x.png", ROOT, "k", "dark", "Nord", "builtin"
        )
        b = tint.tinted_path(
            ROOT / "Dark/Nord/x.png", ROOT, "k", "dark", "Nord", "builtin"
        )
        self.assertNotEqual(a, b)
        self.assertEqual(a.parent, b.parent, "same palette dir, so stems must differ")

    def test_stable_across_calls(self):
        args = (ROOT / "Dynamic/x.png", ROOT, "k", "dark", "Nord", "builtin")
        self.assertEqual(tint.tinted_path(*args), tint.tinted_path(*args))

    def test_palette_key_changes_the_directory(self):
        a = tint.tinted_path(
            ROOT / "Dynamic/x.png", ROOT, "k1", "dark", "Nord", "builtin"
        )
        b = tint.tinted_path(
            ROOT / "Dynamic/x.png", ROOT, "k2", "dark", "Nord", "builtin"
        )
        self.assertNotEqual(a, b)

    def test_path_separators_in_a_palette_name_are_neutralised(self):
        dst = tint.tinted_path(
            ROOT / "Dynamic/x.png", ROOT, "k", "dark", "we/ird", "custom"
        )
        self.assertNotIn("ird", dst.parent.name.split("/")[1:])
        self.assertEqual(len(dst.relative_to(ROOT).parts), 5)

    def test_clut_lives_inside_the_tint_dir(self):
        p = tint._clut_path("key123", ROOT)
        self.assertEqual(p.relative_to(ROOT).parts[:2], (".tinted", ".clut"))

    def test_clut_falls_back_without_a_root(self):
        p = tint._clut_path("key123", None)
        self.assertIn("clut", p.parts)
        self.assertNotIn(".tinted", p.parts)


class TestIsTintedAndKey(unittest.TestCase):
    def test_recognises_own_output(self):
        dst = tint.tinted_path(
            ROOT / "Dynamic/a.png", ROOT, "abc", "dark", "Nord", "builtin"
        )
        self.assertTrue(tint.is_tinted(dst, ROOT))
        self.assertEqual(tint.tinted_key(dst, ROOT), "abc")

    def test_plain_wallpaper_is_not_tinted(self):
        p = ROOT / "Dark/Nord/a.png"
        self.assertFalse(tint.is_tinted(p, ROOT))
        self.assertIsNone(tint.tinted_key(p, ROOT))

    def test_outside_root_is_not_tinted(self):
        self.assertFalse(tint.is_tinted(Path("/tmp/x.png"), ROOT))


class TestManifest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def test_round_trip(self):
        src = self.root / "Dynamic/a.png"
        src.parent.mkdir(parents=True)
        src.write_bytes(b"x")
        dst = tint.tinted_path(src, self.root, "k", "dark", "Nord", "builtin")
        tint.record_manifest(self.root, dst, src)
        self.assertEqual(tint.original_of(dst, self.root), src)

    def test_unknown_tinted_path_returns_none(self):
        dst = tint.tinted_path(
            self.root / "Dynamic/a.png", self.root, "k", "dark", "Nord", "builtin"
        )
        self.assertIsNone(tint.original_of(dst, self.root))

    def test_missing_source_returns_none(self):
        src = self.root / "Dynamic/gone.png"
        dst = tint.tinted_path(src, self.root, "k", "dark", "Nord", "builtin")
        tint.record_manifest(self.root, dst, src)
        self.assertIsNone(tint.original_of(dst, self.root))

    def test_untinted_path_passes_through(self):
        p = self.root / "Dark/Nord/a.png"
        self.assertEqual(tint.original_of(p, self.root), p)

    def test_corrupt_manifest_is_survivable(self):
        mp = tint.manifest_path(self.root)
        mp.parent.mkdir(parents=True, exist_ok=True)
        mp.write_text("{ not json")
        self.assertEqual(tint.load_manifest(self.root), {})


class TestState(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.state = tint.State(self.root / "state.json")

    def tearDown(self):
        self.tmp.cleanup()

    def test_plain_current_is_its_own_source(self):
        p = self.root / "Dark/Nord/a.png"
        self.assertEqual(self.state.source_for("eDP-1", p, self.root), p)

    def test_remembered_source_wins(self):
        src = self.root / "Dynamic/a.png"
        src.parent.mkdir(parents=True)
        src.write_bytes(b"x")
        dst = tint.tinted_path(src, self.root, "k", "dark", "Nord", "builtin")
        self.state.remember("eDP-1", src)
        self.assertEqual(self.state.source_for("eDP-1", dst, self.root), src)

    def test_unknown_tinted_source_is_none(self):
        dst = tint.tinted_path(
            self.root / "Dynamic/a.png", self.root, "k", "dark", "Nord", "builtin"
        )
        self.assertIsNone(self.state.source_for("eDP-1", dst, self.root))

    def test_dedupe_window(self):
        self.assertFalse(self.state.should_dedupe("tok"))
        self.assertTrue(self.state.should_dedupe("tok"))
        self.assertFalse(self.state.should_dedupe("other"))

    def test_survives_a_round_trip_to_disk(self):
        src = self.root / "a.png"
        src.write_bytes(b"x")
        self.state.remember("eDP-1", src)
        self.state.save()
        reloaded = tint.State(self.root / "state.json")
        self.assertEqual(reloaded.data["sources"]["eDP-1"], str(src))


class TestLock(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.path = Path(self.tmp.name) / "l.lock"

    def tearDown(self):
        self.tmp.cleanup()

    def test_second_holder_is_refused_not_blocked(self):
        a = tint.Lock(self.path)
        self.assertTrue(a.acquire())
        b = tint.Lock(self.path)
        self.assertFalse(b.acquire())
        a.release()
        self.assertTrue(b.acquire())
        b.release()

    def test_stale_lock_is_reclaimed(self):
        import os
        import time

        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text("999999")
        old = time.time() - 600
        os.utime(self.path, (old, old))
        self.assertTrue(tint.Lock(self.path, stale_secs=120).acquire())

    def test_context_manager_releases(self):
        with tint.Lock(self.path) as got:
            self.assertTrue(got)
        self.assertTrue(tint.Lock(self.path).acquire())


class TestParamsKey(unittest.TestCase):
    HEXES = ["#2E3440", "#88C0D0", "#A3BE8C"]

    def test_same_inputs_same_key(self):
        p = tint.Params()
        self.assertEqual(
            tint.palette_key(self.HEXES, "dark", "builtin", "Nord", p),
            tint.palette_key(self.HEXES, "dark", "builtin", "Nord", p),
        )

    def test_colors_are_part_of_the_key(self):
        p = tint.Params()
        other = self.HEXES[:-1] + ["#B48EAD"]
        self.assertNotEqual(
            tint.palette_key(self.HEXES, "dark", "community", "X", p),
            tint.palette_key(other, "dark", "community", "X", p),
        )

    def test_parameters_are_part_of_the_key(self):
        self.assertNotEqual(
            tint.palette_key(self.HEXES, "dark", "builtin", "Nord", tint.Params()),
            tint.palette_key(
                self.HEXES, "dark", "builtin", "Nord", tint.Params(power=2.0)
            ),
        )

    def test_mode_is_part_of_the_key(self):
        p = tint.Params()
        self.assertNotEqual(
            tint.palette_key(self.HEXES, "dark", "builtin", "Nord", p),
            tint.palette_key(self.HEXES, "light", "builtin", "Nord", p),
        )

    def test_key_is_filesystem_safe(self):
        key = tint.palette_key(
            self.HEXES, "dark", "builtin", "Rosé Pine", tint.Params()
        )
        self.assertNotIn("/", key)
        self.assertNotIn(" ", key)


if __name__ == "__main__":
    unittest.main()
