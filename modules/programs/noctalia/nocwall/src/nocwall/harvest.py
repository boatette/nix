from __future__ import annotations

import struct
from dataclasses import dataclass

SYMBOL = "_ZN8noctalia5theme12_GLOBAL__N_1L9kPalettesE"

COLORS_PER_VARIANT = 38
COLORS_PER_ENTRY = 76
ENTRY_STRIDE = 16 + COLORS_PER_ENTRY * 16
EXPECTED_COUNT = 10

M3_ROLES = (
    "mPrimary",
    "mOnPrimary",
    "mSecondary",
    "mOnSecondary",
    "mTertiary",
    "mOnTertiary",
    "mError",
    "mOnError",
    "mSurface",
    "mOnSurface",
    "mSurfaceVariant",
    "mOnSurfaceVariant",
    "mOutline",
    "mShadow",
    "mHover",
    "mOnHover",
)
ANSI = ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white")
TERMINAL_EXTRA = (
    "foreground",
    "background",
    "selectionFg",
    "selectionBg",
    "cursorText",
    "cursor",
)


EXPECTED_NAMES = (
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
)

SHT_NOBITS = 8


class HarvestError(RuntimeError):
    pass


@dataclass(frozen=True)
class _Section:
    name_off: int
    sh_type: int
    addr: int
    offset: int
    size: int
    link: int
    name: str = ""


def _sections(data: bytes) -> list[_Section]:
    if data[:4] != b"\x7fELF":
        raise HarvestError("not an ELF file")
    if data[4] != 2:
        raise HarvestError("not ELF64")

    (e_shoff,) = struct.unpack_from("<Q", data, 0x28)
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from("<HHH", data, 0x3A)
    if e_shnum == 0:
        raise HarvestError("no section table (fully stripped binary)")

    raw: list[_Section] = []
    for i in range(e_shnum):
        off = e_shoff + i * e_shentsize
        f = struct.unpack_from("<IIQQQQIIQQ", data, off)
        raw.append(
            _Section(
                name_off=f[0],
                sh_type=f[1],
                addr=f[3],
                offset=f[4],
                size=f[5],
                link=f[6],
            )
        )

    strtab = raw[e_shstrndx]

    def name_at(n: int) -> str:
        start = strtab.offset + n
        end = data.index(b"\0", start)
        return data[start:end].decode("utf-8", "replace")

    return [
        _Section(
            s.name_off, s.sh_type, s.addr, s.offset, s.size, s.link, name_at(s.name_off)
        )
        for s in raw
    ]


def _vaddr_to_offset(secs: list[_Section], vaddr: int) -> int:
    for s in secs:
        if not s.addr or s.sh_type == SHT_NOBITS:
            continue
        if s.addr <= vaddr < s.addr + s.size:
            return s.offset + (vaddr - s.addr)
    raise HarvestError(f"vaddr 0x{vaddr:x} is not inside any mapped section")


def _find_symbol(data: bytes, secs: list[_Section], want: str) -> tuple[int, int]:
    symtab = next((s for s in secs if s.name == ".symtab"), None)
    if symtab is None:
        raise HarvestError(
            "no .symtab -- binary is stripped; palette extraction needs symbols"
        )
    strtab = secs[symtab.link]

    count = symtab.size // 24
    for i in range(count):
        off = symtab.offset + i * 24
        name_off, _info, _other, _shndx, value, size = struct.unpack_from(
            "<IBBHQQ", data, off
        )
        start = strtab.offset + name_off
        end = data.index(b"\0", start)
        if data[start:end].decode("utf-8", "replace") == want:
            return value, size
    raise HarvestError(f"symbol not found: {want}")


def _hex(rgba: tuple[float, float, float, float]) -> str:

    return "#" + "".join(f"{round(max(0.0, min(1.0, c)) * 255):02X}" for c in rgba[:3])


def _variant(colors: list[tuple[float, ...]], base: int) -> dict:
    out: dict = {role: _hex(colors[base + i]) for i, role in enumerate(M3_ROLES)}
    out["terminal"] = {
        "normal": {a: _hex(colors[base + 16 + i]) for i, a in enumerate(ANSI)},
        "bright": {a: _hex(colors[base + 24 + i]) for i, a in enumerate(ANSI)},
    }
    for i, key in enumerate(TERMINAL_EXTRA):
        out["terminal"][key] = _hex(colors[base + 32 + i])
    return out


def harvest(binary_path: str) -> dict[str, dict]:
    with open(binary_path, "rb") as fh:
        data = fh.read()

    secs = _sections(data)
    vaddr, size = _find_symbol(data, secs, SYMBOL)

    if size % ENTRY_STRIDE != 0:
        raise HarvestError(
            f"symbol size {size} is not a multiple of the expected stride "
            f"{ENTRY_STRIDE}; the palette struct layout has changed"
        )
    count = size // ENTRY_STRIDE
    if count != EXPECTED_COUNT:
        raise HarvestError(f"expected {EXPECTED_COUNT} builtin palettes, found {count}")

    base_off = _vaddr_to_offset(secs, vaddr)
    result: dict[str, dict] = {}

    for i in range(count):
        entry = base_off + i * ENTRY_STRIDE
        (name_len,) = struct.unpack_from("<Q", data, entry)
        (name_ptr,) = struct.unpack_from("<Q", data, entry + 8)

        name_off = _vaddr_to_offset(secs, name_ptr)
        end = data.index(b"\0", name_off)
        name = data[name_off:end].decode("utf-8")

        if len(name.encode("utf-8")) != name_len:
            raise HarvestError(
                f"entry {i}: name {name!r} is "
                f"{len(name.encode('utf-8'))} bytes, header says {name_len}"
            )

        colors = [
            struct.unpack_from("<ffff", data, entry + 16 + j * 16)
            for j in range(COLORS_PER_ENTRY)
        ]
        for j, c in enumerate(colors):
            if abs(c[3] - 1.0) > 1e-6:
                raise HarvestError(
                    f"entry {i} ({name}) color {j}: alpha is {c[3]}, expected 1.0 "
                    "-- this array may not be what we think it is"
                )
            for ch in c[:3]:
                if not (-1e-6 <= ch <= 1.0 + 1e-6):
                    raise HarvestError(
                        f"entry {i} ({name}) color {j}: channel {ch} outside 0..1"
                    )

        result[name] = {
            "dark": _variant(colors, 0),
            "light": _variant(colors, COLORS_PER_VARIANT),
        }

    found = tuple(result)
    if found != EXPECTED_NAMES:
        raise HarvestError(
            "builtin palette names changed.\n"
            f"  expected: {EXPECTED_NAMES}\n"
            f"  found:    {found}"
        )

    return result
