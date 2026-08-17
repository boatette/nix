from __future__ import annotations

import hashlib
import json
import os
import time
from dataclasses import dataclass, field
from pathlib import Path

HASH_PREFIX_BYTES = 1 << 20


def journal_path() -> Path:
    env = os.environ.get("XDG_STATE_HOME")
    base = Path(env) if env else Path.home() / ".local/state"
    return base / "nocwall/journal.jsonl"


def batch_id() -> str:
    return (
        time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()) + "-" + os.urandom(2).hex()
    )


def fingerprint(path: str | Path) -> tuple[str, int]:
    st = os.stat(path)
    h = hashlib.sha256()
    h.update(str(st.st_size).encode())
    with open(path, "rb") as fh:
        h.update(fh.read(HASH_PREFIX_BYTES))
    return h.hexdigest()[:16], st.st_size


@dataclass
class Record:
    batch: str
    op: str
    src: str = ""
    dst: str = ""
    size: int = 0
    fp: str = ""
    detail: dict = field(default_factory=dict)

    def to_json(self) -> dict:
        d = {"batch": self.batch, "op": self.op}
        if self.src:
            d["src"] = self.src
        if self.dst:
            d["dst"] = self.dst
        if self.size:
            d["size"] = self.size
        if self.fp:
            d["fp"] = self.fp
        if self.detail:
            d["detail"] = self.detail
        return d


class Journal:
    def __init__(self, path: Path | None = None):
        self.path = path or journal_path()

    def append(self, records: list[Record], *, sync: bool = True):
        if not records:
            return
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.path, "a") as fh:
            for r in records:
                fh.write(json.dumps(r.to_json(), ensure_ascii=False) + "\n")
            fh.flush()
            if sync:
                os.fsync(fh.fileno())

    def read(self) -> list[dict]:
        try:
            with open(self.path) as fh:
                return [json.loads(line) for line in fh if line.strip()]
        except OSError:
            return []

    def batches(self) -> list[str]:
        seen: list[str] = []
        undone: set[str] = set()
        for rec in self.read():
            b = rec.get("batch")
            if not b:
                continue
            if rec.get("op") == "undo":
                undone.add(rec.get("detail", {}).get("target", b))
                continue
            if b not in seen:
                seen.append(b)
        return [b for b in seen if b not in undone]

    def records_for(self, batch: str) -> list[dict]:
        return [r for r in self.read() if r.get("batch") == batch]
