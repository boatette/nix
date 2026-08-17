import unittest

from nocwall import color


class TestLab(unittest.TestCase):
    CASES = [
        ("#FFFFFF", (100.0, 0.0, 0.0)),
        ("#000000", (0.0, 0.0, 0.0)),
        ("#808080", (53.585, 0.0, 0.0)),
        ("#FF0000", (53.241, 80.092, 67.203)),
        ("#00FF00", (87.735, -86.183, 83.179)),
        ("#0000FF", (32.297, 79.188, -107.860)),
    ]

    def test_reference_values(self):
        for hx, expected in self.CASES:
            got = color.hex_to_lab(hx)
            for axis, (g, e) in enumerate(zip(got, expected)):
                self.assertAlmostEqual(
                    g,
                    e,
                    delta=0.01,
                    msg=f"{hx} axis {axis}: {g} != {e}",
                )

    def test_lightness_is_monotonic_in_grey(self):
        greys = [
            color.hex_to_lab(f"#{v:02X}{v:02X}{v:02X}")[0] for v in range(0, 256, 17)
        ]
        self.assertEqual(greys, sorted(greys))

    def test_greys_have_no_chroma(self):
        for v in range(0, 256, 15):
            lab = color.hex_to_lab(f"#{v:02X}{v:02X}{v:02X}")
            self.assertLess(color.chroma(lab), 0.01)

    def test_srgb_linear_roundtrip(self):
        for i in range(0, 101):
            c = i / 100
            self.assertAlmostEqual(
                color.linear_to_srgb(color.srgb_to_linear(c)), c, places=9
            )


class TestOklab(unittest.TestCase):
    def test_white_is_unit_lightness(self):
        l, a, b = color.rgb8_to_oklab(255, 255, 255)
        self.assertAlmostEqual(l, 1.0, places=4)
        self.assertAlmostEqual(a, 0.0, places=4)
        self.assertAlmostEqual(b, 0.0, places=4)

    def test_black_is_zero(self):
        for v in color.rgb8_to_oklab(0, 0, 0):
            self.assertAlmostEqual(v, 0.0, places=6)

    def test_axes_are_not_lab_scale(self):
        _, a_ok, _ = color.rgb8_to_oklab(255, 0, 0)
        _, a_lab, _ = color.rgb8_to_lab(255, 0, 0)
        self.assertLess(abs(a_ok), 1.0)
        self.assertGreater(abs(a_lab), 50.0)


class TestDistance(unittest.TestCase):
    def test_identity_is_zero(self):
        lab = color.hex_to_lab("#7AA2F7")
        self.assertEqual(color.distance(lab, lab), 0.0)

    def test_symmetric(self):
        a = color.hex_to_lab("#7AA2F7")
        b = color.hex_to_lab("#B8BB26")
        self.assertAlmostEqual(color.distance(a, b), color.distance(b, a))

    def test_lightness_is_downweighted(self):
        base = (50.0, 0.0, 0.0)
        lighter = (60.0, 0.0, 0.0)
        shifted = (50.0, 10.0, 0.0)
        self.assertLess(color.distance(base, lighter), color.distance(base, shifted))

    def test_weight_one_is_euclidean(self):
        a, b = (50.0, 3.0, -4.0), (54.0, 0.0, 0.0)
        self.assertAlmostEqual(
            color.distance(a, b, lightness_weight=1.0),
            (16 + 9 + 16) ** 0.5,
        )


class TestHex(unittest.TestCase):
    def test_roundtrip(self):
        for hx in ("#E6B450", "#CBA6F7", "#1A1B26", "#000000", "#FFFFFF"):
            self.assertEqual(color.rgb8_to_hex(*color.hex_to_rgb8(hx)), hx)

    def test_shorthand_and_alpha_and_bare(self):
        self.assertEqual(color.hex_to_rgb8("#abc"), (0xAA, 0xBB, 0xCC))
        self.assertEqual(color.hex_to_rgb8("#1A1B26FF"), (0x1A, 0x1B, 0x26))
        self.assertEqual(color.hex_to_rgb8("1A1B26"), (0x1A, 0x1B, 0x26))

    def test_rejects_garbage(self):
        for bad in ("", "#12345", "not a color", "#GGGGGG"):
            with self.assertRaises(ValueError):
                color.hex_to_rgb8(bad)


if __name__ == "__main__":
    unittest.main()
