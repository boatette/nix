# usage: aion-volume up|down|mute|mic-mute
sink=@DEFAULT_AUDIO_SINK@
source=@DEFAULT_AUDIO_SOURCE@

case "${1:-}" in
  up) wpctl set-volume -l 1.0 "$sink" 5%+ ;;
  down) wpctl set-volume "$sink" 5%- ;;
  mute) wpctl set-mute "$sink" toggle ;;
  mic-mute)
    wpctl set-mute "$source" toggle
    if wpctl get-volume "$source" | grep -q MUTED; then
      notify-send -r 9001 -t 1500 "Microphone muted"
    else
      notify-send -r 9001 -t 1500 "Microphone on"
    fi
    exit 0
    ;;
  *)
    echo "usage: aion-volume up|down|mute|mic-mute" >&2
    exit 1
    ;;
esac

state=$(wpctl get-volume "$sink")
read -r _ fraction _ <<<"$state"
# wpctl prints two decimals ("0.45"), so dropping the dot gives the percentage
percent=$((10#${fraction/./}))
title="Volume"
[[ $state == *MUTED* ]] && title="Volume (muted)"

notify-send -r 9001 -t 1500 -h "int:value:$percent" "$title" "$percent%"
