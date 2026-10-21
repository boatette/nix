# usage: aion-screenshot full|region
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date '+%Y-%m-%d_%H-%M-%S').png"

case "${1:-full}" in
  full) grim "$file" ;;
  region)
    geometry=$(slurp) || exit 0
    grim -g "$geometry" "$file"
    ;;
  *)
    echo "usage: aion-screenshot full|region" >&2
    exit 1
    ;;
esac

wl-copy --type image/png <"$file"
notify-send -t 3000 "Screenshot saved" "$file"
