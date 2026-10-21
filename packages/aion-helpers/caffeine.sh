if systemctl --user is-active --quiet hypridle.service; then
  systemctl --user stop hypridle.service
  notify-send -r 9003 -t 1500 "Caffeine on" "the screen stays awake"
else
  systemctl --user start hypridle.service
  notify-send -r 9003 -t 1500 "Caffeine off" "idle lock and suspend are back"
fi
