import glob
import json
import os
import socket
import sys
import time

CACHE_DIR = os.path.join(
    os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache"),
    "noctalia",
    "zen-browser",
)
CHROME_CSS = os.path.join(CACHE_DIR, "zen-userChrome.css")
CONTENT_CSS = os.path.join(CACHE_DIR, "zen-userContent.css")
LIVE_GLOB = os.path.join(CACHE_DIR, "live-*.css")

HOST = os.environ.get("ZEN_MARIONETTE_HOST", "127.0.0.1")
PORT = int(os.environ.get("ZEN_MARIONETTE_PORT", "2828"))
TIMEOUT = float(os.environ.get("ZEN_MARIONETTE_TIMEOUT", "10"))

SCRIPT = r"""
const [chromeUri, contentUri, staleUris] = arguments;
const winType = Ci.nsIDOMWindowUtils.USER_SHEET;
const svcType = Ci.nsIStyleSheetService.USER_SHEET;
const sss = Cc["@mozilla.org/content/style-sheet-service;1"]
  .getService(Ci.nsIStyleSheetService);

let windows = 0;
for (const win of Services.wm.getEnumerator("navigator:browser")) {
  const utils = win.windowUtils;
  for (const stale of staleUris) {
    try {
      utils.removeSheetUsingURIString(stale, winType);
    } catch (e) {
      // Not loaded in this window; nothing to remove.
    }
  }
  utils.loadSheetUsingURIString(chromeUri, winType);
  windows++;
}

for (const stale of staleUris) {
  const uri = Services.io.newURI(stale);
  if (sss.sheetRegistered(uri, svcType)) {
    sss.unregisterSheet(uri, svcType);
  }
}
sss.loadAndRegisterSheet(Services.io.newURI(contentUri), svcType);

return windows;
"""


class MarionetteError(Exception):
    pass


class Marionette:
    def __init__(self, sock):
        self.sock = sock
        self.buf = b""
        self.seq = 0

    def _fill(self):
        chunk = self.sock.recv(65536)
        if not chunk:
            raise MarionetteError("Marionette closed the connection")
        self.buf += chunk

    def _recv(self):
        while b":" not in self.buf:
            self._fill()

        length, _, rest = self.buf.partition(b":")
        length = int(length)

        while len(rest) < length:
            self.buf = rest
            self._fill()
            rest = self.buf

        self.buf = rest[length:]
        return json.loads(rest[:length])

    def handshake(self):
        return self._recv()

    def call(self, name, params=None):
        self.seq += 1
        seq = self.seq

        body = json.dumps([0, seq, name, params or {}]).encode("utf-8")
        self.sock.sendall(str(len(body)).encode("ascii") + b":" + body)

        while True:
            msg = self._recv()
            if not (isinstance(msg, list) and len(msg) == 4):
                continue
            if msg[0] != 1 or msg[1] != seq:
                continue
            if msg[2] is not None:
                raise MarionetteError(json.dumps(msg[2]))
            return msg[3]


def read(path):
    with open(path, "r", encoding="utf-8") as handle:
        return handle.read()


def write_live(stamp, kind, source):
    path = os.path.join(CACHE_DIR, f"live-{stamp}-{kind}.css")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(source)
    return path


def as_uri(path):
    return "file://" + path


def main():
    for path in (CHROME_CSS, CONTENT_CSS):
        if not os.path.exists(path):
            print(
                f"zen-theme-reload: {path} missing, nothing to apply",
                file=sys.stderr,
            )
            return 0

    stale = sorted(glob.glob(LIVE_GLOB))

    try:
        sock = socket.create_connection((HOST, PORT), timeout=TIMEOUT)
    except OSError:
        return 0

    sock.settimeout(TIMEOUT)

    stamp = f"{int(time.time())}-{os.getpid()}"
    chrome_path = write_live(stamp, "chrome", read(CHROME_CSS))
    content_path = write_live(stamp, "content", read(CONTENT_CSS))

    client = Marionette(sock)
    session = False

    try:
        client.handshake()
        client.call("WebDriver:NewSession", {})
        session = True
        client.call("Marionette:SetContext", {"value": "chrome"})
        windows = client.call(
            "WebDriver:ExecuteScript",
            {
                "script": SCRIPT,
                "args": [
                    as_uri(chrome_path),
                    as_uri(content_path),
                    [as_uri(p) for p in stale],
                ],
                "sandbox": "system",
                "newSandbox": True,
            },
        )
    except (MarionetteError, OSError) as err:
        for path in (chrome_path, content_path):
            os.unlink(path)
        print(f"zen-theme-reload: {err}", file=sys.stderr)
        return 1
    finally:
        if session:
            try:
                client.call("WebDriver:DeleteSession", {})
            except (MarionetteError, OSError):
                pass
        sock.close()

    for path in stale:
        try:
            os.unlink(path)
        except OSError:
            pass

    value = windows.get("value") if isinstance(windows, dict) else windows
    print(f"zen-theme-reload: reloaded {value} window(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
