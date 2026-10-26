# usage: aion-power lock|suspend|reboot|shutdown
case "${1:-}" in
  lock) swaylock -f ;;
  suspend) swaylock -f && systemctl suspend ;;
  reboot) systemctl reboot ;;
  shutdown) systemctl poweroff ;;
  *)
    echo "usage: aion-power lock|suspend|reboot|shutdown" >&2
    exit 1
    ;;
esac
