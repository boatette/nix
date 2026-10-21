# usage: aion-brightness up|down [step%]
step="${2:-5}"

case "${1:-}" in
  up) brightnessctl -q set "$step%+" ;;
  down) brightnessctl -q set "$step%-" ;;
  *)
    echo "usage: aion-brightness up|down [step]" >&2
    exit 1
    ;;
esac

percent=$(brightnessctl -m | cut -d, -f4)
percent=${percent%\%}

notify-send -r 9002 -t 1500 -h "int:value:$percent" "Brightness" "$percent%"
