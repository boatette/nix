# the server is the llm user service (modules/services/llm.nix); this starts it, runs opencode on
# it and downloads the models it serves

url=http://127.0.0.1:$PORT

missing() {
  jq -r '.[] | "\(.file)\t\(.name)"' "$MODELS_JSON" | while IFS=$'\t' read -r file name; do
    [ -f "$ROOT/models/$file" ] || echo "  $name"
  done
}

running() {
  systemctl --user is-active --quiet llm.service
}

serve() {
  local gone
  gone=$(missing)
  if [ -n "$gone" ]; then
    echo "Not downloaded yet (llm models), so these won't load:" >&2
    echo "$gone" >&2
  fi
  # comfyui's cap alone is 12G of this machine's 16
  if systemctl --user is-active --quiet comfyui.scope; then
    echo "ComfyUI is running and the two don't fit in memory together; stop it first" >&2
    exit 1
  fi
  systemctl --user reset-failed llm.service 2>/dev/null || true
  systemctl --user start llm.service
  until curl -sf -o /dev/null "$url/health"; do
    running || {
      echo "the server stopped; see llm log" >&2
      exit 1
    }
    sleep 1
  done
}

start() {
  if running; then
    echo "Already running at $url"
  else
    serve
  fi
  if [ -t 1 ]; then
    xdg-open "$url" >/dev/null 2>&1 || true
  fi
  echo "Chat at $url (llm stop ends it; the first message to a model waits for it to load)"
}

code() {
  running || serve
  # --standalone: its own server for this run, not a background service left behind
  exec opencode --standalone "$@"
}

# the status and size of a download, after redirects; a one-byte GET rather than HEAD, which
# storage links can refuse
probe() {
  curl -sL -m 60 -r 0-0 -D - -o /dev/null "$1" | tr -d '\r' |
    awk 'tolower($1) ~ /^http\// { code = $2 } tolower($1) == "content-range:" { split($3, a, "/"); n = a[2] } END { print code, n + 0 }'
}

# hugging face drops long connections, so resumable curl, then the hash. a connection that dies
# without closing (a vpn switching servers) stalls instead, so under 10 KB/s for a minute aborts it
# and the retry picks up where it stopped
fetch() {
  local url=$1 sha256=$2 dest=$3
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if curl -fsSL --retry 5 --retry-all-errors --speed-limit 10240 --speed-time 60 -C - -o "$dest.part" "$url"; then
      if echo "$sha256  $dest.part" | sha256sum -c --status; then
        mv "$dest.part" "$dest"
        rm -f "$dest.size"
        echo "$dest: done"
        return
      fi
      echo "$dest: checksum mismatch, downloading again" >&2
      rm -f "$dest.part"
    fi
    sleep 10
  done
  echo "$dest: download failed; run llm models again" >&2
}

# curl is silent, so say how far each download has got every half minute
report() {
  local part have want
  while sleep 30; do
    for part in models/*.part; do
      # only the ones growing: a .part left by an earlier, stopped run waits for its turn
      [ -n "$(find "$part" -mmin -1 2>/dev/null)" ] || continue
      have=$(stat -c %s "$part")
      want=$(cat "${part%.part}.size" 2>/dev/null || echo 0)
      if [ "$want" -gt 0 ]; then
        echo "  ${part%.part}: $(numfmt --to=iec "$have") of $(numfmt --to=iec "$want") ($((have * 100 / want))%)"
      fi
    done
  done
}

models() {
  local filter=${1:-} lock name url sha256 file code size reporter
  cd "$ROOT"
  mkdir -p models
  # two downloaders appending to the same .part file corrupt it
  exec {lock}>models/.lock
  if ! flock -n "$lock"; then
    echo "llm models is already running" >&2
    exit 1
  fi
  report &
  reporter=$!
  while IFS=$'\t' read -r name url sha256 file; do
    [ -z "$filter" ] || [[ $name == *"$filter"* ]] || continue
    [ -f "models/$file" ] && continue
    read -r code size < <(probe "$url")
    case $code in
      2*) ;;
      *) echo "$name: HTTP ${code:-error}, skipped" >&2 && continue ;;
    esac
    echo "$size" >"models/$file.size"
    echo "$name: downloading $(numfmt --to=iec "$size")"
    # two at a time; the reporter is one of the jobs
    while (($(jobs -rp | wc -l) >= 3)); do wait -n || true; done
    fetch "$url" "$sha256" "models/$file" &
  done < <(jq -r '.[] | [.name, .url, .sha256, .file] | @tsv' "$MODELS_JSON")
  while (($(jobs -rp | wc -l) > 1)); do wait -n || true; done
  kill "$reporter"

  local gone
  gone=$(missing)
  if [ -z "$gone" ]; then
    echo "All models are in."
  else
    echo "Still missing:" >&2
    echo "$gone" >&2
  fi
}

case ${1:-start} in
  start) start ;;
  stop) systemctl --user stop llm.service ;;
  code) code "${@:2}" ;;
  log) journalctl --user -u llm -f ;;
  models) models "${2:-}" ;;
  *)
    cat >&2 <<EOF
usage: llm [start]        run the server and open the chat page
       llm stop           stop the server
       llm code [DIR]     the opencode coding agent on the local models, in DIR (or here)
       llm log            follow the server's log
       llm models [NAME]  download the models (or those whose name has NAME)
EOF
    exit 1
    ;;
esac
