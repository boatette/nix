import tempfile
import unittest
from pathlib import Path

from nocwall import classify, features, journal, sort


def cand(folder, mode, hexes, name=None, source="builtin"):
    return classify.Candidate.from_hexes(name or folder, folder, source, mode, hexes)


def feats(clusters, l_star=20.0):
    return features.Features(clusters=list(clusters), l_star=l_star, n_samples=4096)


NORD = ["#2E3440", "#3B4252", "#88C0D0", "#81A1C1", "#5E81AC", "#D8DEE9"]
GRUV = ["#282828", "#3C3836", "#FB4934", "#FE8019", "#FABD2F", "#EBDBB2"]
MONO = ["#111111", "#3C3C3C", "#828282", "#AAAAAA", "#DDDDDD", "#FFFFFF"]


class TestGates(unittest.TestCase):
    def setUp(self):
        self.cands = [
            cand("Nord", "dark", NORD),
            cand("Gruvbox", "dark", GRUV),
            cand("Monochrome", "dark", MONO),
        ]

    def _clusters_near(self, hexes):
        from nocwall import color

        w = 1.0 / len(hexes)
        return [(*color.hex_to_lab(h), w) for h in hexes]

    def test_exact_palette_match_is_accepted(self):
        d = classify.classify(
            "x.png", feats(self._clusters_near(NORD)), self.cands, mode="dark"
        )
        self.assertTrue(d.accepted, d.reason)
        self.assertEqual(d.best.candidate.folder, "Nord")

    def test_no_fit_is_rejected_even_when_unambiguous(self):
        wild = ["#FF00FF", "#00FF00", "#FF0080", "#80FF00"]
        d = classify.classify(
            "x.png",
            feats(self._clusters_near(wild)),
            self.cands,
            mode="dark",
            max_distance=5.0,
            min_margin=0.0,
        )
        self.assertFalse(d.accepted)
        self.assertEqual(d.reason, "no-fit")

    def test_ambiguous_is_rejected(self):
        nord_clone = [h for h in NORD]
        nord_clone[2] = "#89C1D1"
        cands = [cand("Nord", "dark", NORD), cand("NordClone", "dark", nord_clone)]

        between = ["#2E3440", "#3B4252", "#88C1D1", "#81A1C1"]
        d = classify.classify(
            "x.png",
            feats(self._clusters_near(between)),
            cands,
            mode="dark",
            max_distance=1e9,
            min_margin=0.30,
        )
        self.assertFalse(d.accepted)
        self.assertEqual(d.reason, "ambiguous")
        self.assertLess(d.margin, 0.30)

    def test_exact_match_is_never_ambiguous(self):
        d = classify.classify(
            "x.png",
            feats(self._clusters_near(NORD)),
            self.cands,
            mode="dark",
            min_margin=0.99,
        )
        self.assertTrue(d.accepted, d.reason)
        self.assertAlmostEqual(d.margin, 1.0, places=6)

    def test_mode_comes_from_l_star(self):
        cands = self.cands + [cand("Nord", "light", ["#ECEFF4", "#E5E9F0"])]
        dark = classify.classify(
            "x", feats(self._clusters_near(NORD), l_star=20), cands, luma_threshold=45
        )
        light = classify.classify(
            "x", feats(self._clusters_near(NORD), l_star=80), cands, luma_threshold=45
        )
        self.assertEqual(dark.mode, "dark")
        self.assertEqual(light.mode, "light")

    def test_no_candidates_for_mode(self):
        d = classify.classify(
            "x",
            feats(self._clusters_near(NORD)),
            [cand("Nord", "light", NORD)],
            mode="dark",
        )
        self.assertFalse(d.accepted)
        self.assertEqual(d.reason, "no-candidates")

    def test_separation_is_symmetric_and_positive(self):
        a, b = self.cands[0], self.cands[1]
        self.assertAlmostEqual(classify.separation(a, b), classify.separation(b, a))
        self.assertGreater(classify.separation(a, b), 0)

    def test_reverse_score_penalises_missing_accents(self):
        from nocwall import color

        grey = [
            (*color.hex_to_lab(h), 0.25)
            for h in ("#111111", "#3C3C3C", "#AAAAAA", "#DDDDDD")
        ]
        mono_rev = classify.reverse_score(grey, self.cands[2].labs)
        gruv_rev = classify.reverse_score(grey, self.cands[1].labs)
        self.assertLess(mono_rev, gruv_rev)


class TestCollisions(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def _write(self, rel, content=b"data"):
        p = self.root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(content)
        return p

    def test_free_destination(self):
        src = self._write("Dynamic/a.png")
        dst = self.root / "Dark/Nord/a.png"
        self.assertEqual(sort.resolve_collision(src, dst), (dst, "move"))

    def test_identical_content_is_dedupe(self):
        src = self._write("Dynamic/a.png", b"same")
        dst = self._write("Dark/Nord/a.png", b"same")
        got, op = sort.resolve_collision(src, dst)
        self.assertEqual(op, "dedupe")
        self.assertEqual(got, dst)

    def test_different_content_gets_a_suffix(self):
        src = self._write("Dynamic/a.png", b"one")
        dst = self._write("Dark/Nord/a.png", b"two")
        got, op = sort.resolve_collision(src, dst)
        self.assertEqual(op, "move-renamed")
        self.assertEqual(got.name, "a (2).png")

    def test_suffix_increments_past_existing(self):
        src = self._write("Dynamic/a.png", b"one")
        self._write("Dark/Nord/a.png", b"two")
        self._write("Dark/Nord/a (2).png", b"three")
        got, _ = sort.resolve_collision(src, self.root / "Dark/Nord/a.png")
        self.assertEqual(got.name, "a (3).png")

    def test_never_returns_an_existing_path_for_a_move(self):
        src = self._write("Dynamic/a.png", b"one")
        self._write("Dark/Nord/a.png", b"two")
        got, op = sort.resolve_collision(src, self.root / "Dark/Nord/a.png")
        self.assertEqual(op, "move-renamed")
        self.assertFalse(got.exists())


class TestMirror(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def test_matches_on_stem_across_extensions(self):
        (self.root / "Dynamic").mkdir(parents=True)
        (self.root / "Dynamic/a.png").write_bytes(b"x")
        (self.root / "_optimised/Dynamic").mkdir(parents=True)
        (self.root / "_optimised/Dynamic/a.webp").write_bytes(b"y")
        got = sort.mirror_counterpart(
            self.root, "_optimised", self.root / "Dynamic/a.png"
        )
        self.assertIsNotNone(got)
        self.assertEqual(got.name, "a.webp")

    def test_absent_mirror_is_none(self):
        (self.root / "Dynamic").mkdir(parents=True)
        (self.root / "Dynamic/a.png").write_bytes(b"x")
        self.assertIsNone(
            sort.mirror_counterpart(
                self.root, "_optimised", self.root / "Dynamic/a.png"
            )
        )
        self.assertIsNone(
            sort.mirror_counterpart(self.root, "", self.root / "Dynamic/a.png")
        )


class TestApplyUndo(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name) / "wp"
        (self.root / "Dynamic").mkdir(parents=True)
        self.jpath = Path(self.tmp.name) / "journal.jsonl"
        self.jrnl = journal.Journal(self.jpath)

    def tearDown(self):
        self.tmp.cleanup()

    def _move(self, name, folder="Nord", mode="dark", content=b"payload"):
        src = self.root / "Dynamic" / name
        src.write_bytes(content)
        return sort.Move(src, self.root / mode.capitalize() / folder / name, "move")

    def test_apply_then_undo_restores_exactly(self):
        moves = [self._move(f"a{i}.png", content=bytes([i]) * 2048) for i in range(4)]
        before = {m.src: m.src.read_bytes() for m in moves}

        batch, done = sort.apply_moves(moves, jrnl=self.jrnl)
        self.assertEqual(len(done), 4)
        for m in moves:
            self.assertFalse(m.src.exists())
            self.assertTrue(m.dst.exists())

        count, problems = sort.undo_batch(batch, jrnl=self.jrnl)
        self.assertEqual(count, 4)
        self.assertEqual(problems, [])
        for src, content in before.items():
            self.assertTrue(src.exists())
            self.assertEqual(src.read_bytes(), content)

    def test_undo_removes_emptied_directories_and_their_parents(self):
        m = self._move("a.png")
        batch, _ = sort.apply_moves([m], jrnl=self.jrnl)
        sort.undo_batch(batch, jrnl=self.jrnl)
        self.assertFalse((self.root / "Dark/Nord").exists())
        self.assertFalse((self.root / "Dark").exists())

    def test_undo_refuses_when_the_file_changed(self):
        m = self._move("a.png")
        batch, _ = sort.apply_moves([m], jrnl=self.jrnl)
        m.dst.write_bytes(b"edited since the move")
        count, problems = sort.undo_batch(batch, jrnl=self.jrnl)
        self.assertEqual(count, 0)
        self.assertTrue(problems)
        self.assertTrue(m.dst.exists(), "must not have moved the changed file")

    def test_undo_refuses_when_the_source_reappeared(self):
        m = self._move("a.png")
        batch, _ = sort.apply_moves([m], jrnl=self.jrnl)
        m.src.write_bytes(b"something else now lives here")
        count, problems = sort.undo_batch(batch, jrnl=self.jrnl)
        self.assertEqual(count, 0)
        self.assertTrue(problems)
        self.assertEqual(m.src.read_bytes(), b"something else now lives here")

    def test_journal_is_written_before_moves(self):
        moves = [self._move("a.png")]
        batch, _ = sort.apply_moves(moves, jrnl=self.jrnl)
        recs = self.jrnl.records_for(batch)
        self.assertEqual(len(recs), 1)
        self.assertEqual(recs[0]["op"], "move")
        self.assertIn("fp", recs[0])

    def test_dry_run_writes_nothing(self):
        moves = [self._move("a.png")]
        batch, done = sort.apply_moves(moves, dry_run=True, jrnl=self.jrnl)
        self.assertEqual(done, [])
        self.assertTrue(moves[0].src.exists())
        self.assertFalse(self.jpath.exists())

    def test_batches_excludes_undone(self):
        m = self._move("a.png")
        batch, _ = sort.apply_moves([m], jrnl=self.jrnl)
        self.assertIn(batch, self.jrnl.batches())
        sort.undo_batch(batch, jrnl=self.jrnl)
        self.assertNotIn(batch, self.jrnl.batches())

    def test_dedupe_leaves_source_in_place(self):
        src = self.root / "Dynamic/a.png"
        src.write_bytes(b"same")
        dst = self.root / "Dark/Nord/a.png"
        dst.parent.mkdir(parents=True)
        dst.write_bytes(b"same")
        _batch, done = sort.apply_moves([sort.Move(src, dst, "dedupe")], jrnl=self.jrnl)
        self.assertEqual(len(done), 1)
        self.assertTrue(src.exists(), "a duplicate source must not be deleted")
        self.assertEqual(dst.read_bytes(), b"same")


class TestRootGuard(unittest.TestCase):
    def test_stops_at_home(self):
        self.assertEqual(sort.root_guard(Path.home() / "a/b"), Path.home())

    def test_outside_home_stops_at_anchor(self):
        self.assertEqual(sort.root_guard(Path("/tmp/x/y")), Path("/"))


class TestFingerprint(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()

    def tearDown(self):
        self.tmp.cleanup()

    def _f(self, name, content):
        p = Path(self.tmp.name) / name
        p.write_bytes(content)
        return p

    def test_same_content_same_fingerprint(self):
        a = self._f("a", b"x" * 5000)
        b = self._f("b", b"x" * 5000)
        self.assertEqual(journal.fingerprint(a), journal.fingerprint(b))

    def test_size_difference_detected(self):
        a = self._f("a", b"x" * 5000)
        b = self._f("b", b"x" * 5001)
        self.assertNotEqual(journal.fingerprint(a), journal.fingerprint(b))

    def test_content_difference_detected(self):
        a = self._f("a", b"x" * 5000)
        b = self._f("b", b"y" * 5000)
        self.assertNotEqual(journal.fingerprint(a), journal.fingerprint(b))

    def test_difference_beyond_the_hashed_prefix_is_caught_by_size(self):
        big = b"z" * (journal.HASH_PREFIX_BYTES + 10)
        a = self._f("a", big)
        b = self._f("b", big + b"tail")
        self.assertNotEqual(journal.fingerprint(a), journal.fingerprint(b))


if __name__ == "__main__":
    unittest.main()
