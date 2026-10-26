# holds an idle inhibitor, which hypridle honours while still locking before sleep
unit=aion-caffeine

if systemctl --user is-active --quiet "$unit"; then
  systemctl --user stop "$unit"
  notify-send -r 9003 -t 1500 "Caffeine off" "idle lock and suspend are back"
else
  systemd-run --user --quiet --collect --unit="$unit" \
    "$(command -v systemd-inhibit)" --what=idle --who="$unit" --why="Caffeine is on" "$(command -v sleep)" infinity
  notify-send -r 9003 -t 1500 "Caffeine on" "the screen stays awake"
fi
