import shutil
import unittest
from pathlib import Path

from nocwall import harvest, palette, settings


def _noctalia_elf():
    try:
        return palette._resolve_noctalia_elf()
    except Exception:
        return None


ELF = _noctalia_elf()
HAVE_ELF = ELF is not None and Path(ELF).exists()
HAVE_CLI = shutil.which(palette._noctalia_bin()) is not None


class TestNorm(unittest.TestCase):
    def test_diacritics_and_punctuation(self):
        self.assertEqual(palette.norm("Rose-Pine"), palette.norm("Rosé Pine"))
        self.assertEqual(palette.norm("Rosé Pine"), "rosepine")
        self.assertEqual(palette.norm("Tokyo-Night"), "tokyonight")
        self.assertEqual(palette.norm("Everforest Alt"), "everforestalt")

    def test_case_insensitive(self):
        self.assertEqual(palette.norm("CATPPUCCIN"), palette.norm("catppuccin"))

    def test_empty(self):
        self.assertEqual(palette.norm(""), "")
        self.assertEqual(palette.norm("---"), "")

    def test_distinct_names_stay_distinct(self):
        names = [
            "Ayu",
            "Catppuccin",
            "Dracula",
            "Eldritch",
            "Gruvbox",
            "Kanagawa",
            "Noctalia",
            "Nord",
            "Rosé Pine",
            "Tokyo-Night",
        ]
        keys = [palette.norm(n) for n in names]
        self.assertEqual(len(set(keys)), len(keys), "folding collided")


class TestUrlDecode(unittest.TestCase):
    def test_space_and_utf8(self):
        self.assertEqual(palette._url_decode("Everforest%20Alt"), "Everforest Alt")
        self.assertEqual(palette._url_decode("Ros%C3%A9%20Pine"), "Rosé Pine")

    def test_passthrough(self):
        self.assertEqual(palette._url_decode("Monochrome"), "Monochrome")

    def test_malformed_percent_is_literal(self):
        self.assertEqual(palette._url_decode("100%"), "100%")
        self.assertEqual(palette._url_decode("a%zz"), "a%zz")


@unittest.skipUnless(HAVE_ELF, "noctalia binary not available")
class TestHarvest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pals = harvest.harvest(ELF)

    def test_all_ten_in_binary_order(self):
        self.assertEqual(tuple(self.pals), harvest.EXPECTED_NAMES)

    def test_published_primaries(self):
        expected = {
            "Ayu": "#E6B450",
            "Catppuccin": "#CBA6F7",
            "Dracula": "#BD93F9",
            "Gruvbox": "#B8BB26",
            "Nord": "#8FBCBB",
            "Rosé Pine": "#EBBCBA",
            "Tokyo-Night": "#7AA2F7",
        }
        for name, hexv in expected.items():
            self.assertEqual(self.pals[name]["dark"]["mPrimary"], hexv, name)

    def test_catppuccin_mocha_ansi(self):
        self.assertEqual(
            self.pals["Catppuccin"]["dark"]["terminal"]["normal"],
            {
                "black": "#45475A",
                "red": "#F38BA8",
                "green": "#A6E3A1",
                "yellow": "#F9E2AF",
                "blue": "#89B4FA",
                "magenta": "#F5C2E7",
                "cyan": "#94E2D5",
                "white": "#A6ADC8",
            },
        )

    def test_tokyo_night_surface_and_selection(self):
        dark = self.pals["Tokyo-Night"]["dark"]
        self.assertEqual(dark["mSurface"], "#1A1B26")
        self.assertEqual(dark["terminal"]["selectionBg"], "#283457")

    def test_both_variants_present_and_distinct(self):
        for name, variants in self.pals.items():
            self.assertIn("dark", variants)
            self.assertIn("light", variants)
            self.assertNotEqual(
                variants["dark"]["mSurface"],
                variants["light"]["mSurface"],
                f"{name}: dark and light share a surface",
            )

    def test_light_surfaces_are_lighter(self):
        from nocwall import color

        for name, variants in self.pals.items():
            dark_l = color.hex_to_lab(variants["dark"]["mSurface"])[0]
            light_l = color.hex_to_lab(variants["light"]["mSurface"])[0]
            self.assertGreater(light_l, dark_l, f"{name}")

    def test_every_role_is_a_hex_color(self):
        for name, variants in self.pals.items():
            for mode, v in variants.items():
                for role in harvest.M3_ROLES:
                    self.assertRegex(
                        v[role], r"^#[0-9A-F]{6}$", f"{name}.{mode}.{role}"
                    )

    def test_rejects_non_elf(self):
        with self.assertRaises(harvest.HarvestError):
            harvest.harvest(__file__)

    def test_rejects_missing_file(self):
        with self.assertRaises((OSError, harvest.HarvestError)):
            harvest.harvest("/nonexistent/noctalia")


@unittest.skipUnless(HAVE_ELF and HAVE_CLI, "noctalia binary/CLI not available")
class TestExpand(unittest.TestCase):
    def test_terminal_tokens_pass_through_verbatim(self):
        seed = palette.seed_for("builtin", "Nord", "dark")
        colors = palette.expand(seed, "dark")
        colors = colors.get("colors", colors)

        def tok(name):
            v = colors.get(name)
            return v.get("hex") if isinstance(v, dict) else v

        for word in ("normal", "bright"):
            for ansi, want in seed["terminal"][word].items():
                got = tok(f"terminal_{word}_{ansi}")
                self.assertEqual(got.upper(), want.upper(), f"{word}.{ansi}")

    def test_core_accents_pass_through(self):
        seed = palette.seed_for("builtin", "Tokyo-Night", "dark")
        colors = palette.expand(seed, "dark")
        colors = colors.get("colors", colors)

        def tok(name):
            v = colors.get(name)
            return v.get("hex") if isinstance(v, dict) else v

        self.assertEqual(tok("primary").upper(), seed["mPrimary"].upper())
        self.assertEqual(tok("surface").upper(), seed["mSurface"].upper())

    def test_outline_is_rederived_not_passed_through(self):
        seed = palette.seed_for("builtin", "Nord", "dark")
        colors = palette.expand(seed, "dark")
        colors = colors.get("colors", colors)
        v = colors.get("outline")
        got = v.get("hex") if isinstance(v, dict) else v
        self.assertNotEqual(got.upper(), seed["mOutline"].upper())

    def test_tint_colors_are_unique_hexes(self):
        seed = palette.seed_for("builtin", "Gruvbox", "dark")
        tints = palette.tint_colors(palette.expand(seed, "dark"))
        self.assertEqual(len(tints), len(set(tints)))
        self.assertGreaterEqual(len(tints), 8)
        for t in tints:
            self.assertRegex(t, r"^#[0-9a-fA-F]{6}$")

    def test_unknown_palette_raises(self):
        with self.assertRaises(LookupError):
            palette.seed_for("builtin", "NoSuchPalette", "dark")

    def test_generated_source_has_no_seed(self):
        with self.assertRaises(ValueError):
            palette.seed_for("wallpaper", "vibrant", "dark")


class TestSettings(unittest.TestCase):
    SAMPLE = """
config_version = 12

[theme]
builtin = "Tokyo-Night"
community_palette = "Monochrome"
custom_palette = "Wallust"
mode = "dark"
source = "builtin"
wallpaper_scheme = "vibrant"

[wallpaper.default]
path = "/w/default.png"

[wallpaper.last]
path = "/w/last.png"

[wallpaper.monitors.eDP-1]
path = "/w/edp.png"

[wallpaper.monitors.HDMI-A-1]
path = "/w/hdmi.png"
"""

    def _load(self, text):
        import tempfile

        with tempfile.NamedTemporaryFile("w", suffix=".toml", delete=False) as fh:
            fh.write(text)
            name = fh.name
        try:
            return settings.load(name)
        finally:
            Path(name).unlink()

    def test_selection_follows_source(self):
        st = self._load(self.SAMPLE)
        self.assertEqual(st.theme.selection, "Tokyo-Night")
        self.assertFalse(st.theme.is_generated)

    def test_generated_source(self):
        st = self._load(
            self.SAMPLE.replace('source = "builtin"', 'source = "wallpaper"')
        )
        self.assertEqual(st.theme.selection, "vibrant")
        self.assertTrue(st.theme.is_generated)

    def test_per_monitor_wins_over_last(self):
        st = self._load(self.SAMPLE)
        self.assertEqual(
            st.wallpapers.targets(),
            {"eDP-1": "/w/edp.png", "HDMI-A-1": "/w/hdmi.png"},
        )

    def test_falls_back_to_last_then_default(self):
        no_mon = self.SAMPLE.split("[wallpaper.monitors.eDP-1]")[0]
        self.assertEqual(self._load(no_mon).wallpapers.targets(), {"": "/w/last.png"})
        only_default = no_mon.split("[wallpaper.last]")[0]
        self.assertEqual(
            self._load(only_default).wallpapers.targets(), {"": "/w/default.png"}
        )

    def test_empty_theme_defaults(self):
        st = self._load("config_version = 12\n")
        self.assertEqual(st.theme.source, "builtin")
        self.assertEqual(st.theme.mode, "dark")
        self.assertEqual(st.wallpapers.targets(), {})


@unittest.skipUnless(HAVE_ELF, "noctalia binary not available")
class TestSeedSchemaMatchesOnDisk(unittest.TestCase):
    def test_shapes_match(self):
        community = palette.load_community()
        if not community:
            self.skipTest("no community palettes downloaded")
        _name, on_disk = next(iter(community.values()))
        harvested = palette.seed_for("builtin", "Nord", "dark")

        disk_keys = set(on_disk["dark"]) & set(harvest.M3_ROLES)
        self.assertTrue(disk_keys)
        for key in disk_keys:
            self.assertIn(key, harvested)
        self.assertIn("terminal", harvested)
        self.assertIn("normal", harvested["terminal"])


if __name__ == "__main__":
    unittest.main()
