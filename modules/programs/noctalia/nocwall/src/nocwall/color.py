from __future__ import annotations


_WHITE_X = 0.95047
_WHITE_Y = 1.00000
_WHITE_Z = 1.08883

_EPS = 216 / 24389
_KAPPA = 24389 / 27


def srgb_to_linear(c: float) -> float:
    if c <= 0.04045:
        return c / 12.92
    return ((c + 0.055) / 1.055) ** 2.4


def linear_to_srgb(c: float) -> float:
    if c <= 0.0031308:
        return c * 12.92
    return 1.055 * (c ** (1 / 2.4)) - 0.055


def _f(t: float) -> float:
    if t > _EPS:
        return t ** (1 / 3)
    return (_KAPPA * t + 16) / 116


def rgb8_to_lab(r: int, g: int, b: int) -> tuple[float, float, float]:
    rl = srgb_to_linear(r / 255)
    gl = srgb_to_linear(g / 255)
    bl = srgb_to_linear(b / 255)

    x = (0.4124564 * rl + 0.3575761 * gl + 0.1804375 * bl) / _WHITE_X
    y = (0.2126729 * rl + 0.7151522 * gl + 0.0721750 * bl) / _WHITE_Y
    z = (0.0193339 * rl + 0.1191920 * gl + 0.9503041 * bl) / _WHITE_Z

    fx, fy, fz = _f(x), _f(y), _f(z)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))


def rgb8_to_oklab(r: int, g: int, b: int) -> tuple[float, float, float]:
    rl = srgb_to_linear(r / 255)
    gl = srgb_to_linear(g / 255)
    bl = srgb_to_linear(b / 255)

    l = 0.4122214708 * rl + 0.5363325363 * gl + 0.0514459929 * bl
    m = 0.2119034982 * rl + 0.6806995451 * gl + 0.1073969566 * bl
    s = 0.0883024619 * rl + 0.2817188376 * gl + 0.6299787005 * bl

    l_ = l ** (1 / 3) if l > 0 else -((-l) ** (1 / 3))
    m_ = m ** (1 / 3) if m > 0 else -((-m) ** (1 / 3))
    s_ = s ** (1 / 3) if s > 0 else -((-s) ** (1 / 3))

    return (
        0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
        1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
        0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
    )


def hex_to_rgb8(s: str) -> tuple[int, int, int]:
    h = s.strip().lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    if len(h) == 8:
        h = h[:6]
    if len(h) != 6:
        raise ValueError(f"not a hex color: {s!r}")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


def rgb8_to_hex(r: int, g: int, b: int) -> str:
    return f"#{r:02X}{g:02X}{b:02X}"


def hex_to_lab(s: str) -> tuple[float, float, float]:
    return rgb8_to_lab(*hex_to_rgb8(s))


LIGHTNESS_WEIGHT = 0.35


def distance(
    a: tuple[float, float, float],
    b: tuple[float, float, float],
    lightness_weight: float = LIGHTNESS_WEIGHT,
) -> float:
    dl = a[0] - b[0]
    da = a[1] - b[1]
    db = a[2] - b[2]
    return (da * da + db * db + lightness_weight * dl * dl) ** 0.5


def chroma(lab: tuple[float, float, float]) -> float:
    return (lab[1] * lab[1] + lab[2] * lab[2]) ** 0.5
