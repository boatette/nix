if systemctl --user is-active --quiet swayidle.service; then
  systemctl --user stop swayidle.service
  notify-send -r 9003 -t 1500 "Caffeine on" "the screen stays awake"
else
  systemctl --user start swayidle.service
  notify-send -r 9003 -t 1500 "Caffeine off" "idle lock and suspend are back"
fi
