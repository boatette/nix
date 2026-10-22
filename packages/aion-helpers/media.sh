# usage: aion-media play-pause|next|previous
case "${1:-}" in
  play-pause | next | previous) playerctl "$1" ;;
  *)
    echo "usage: aion-media play-pause|next|previous" >&2
    exit 1
    ;;
esac
