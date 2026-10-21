case "$1" in
  lock) swaylock -f ;;
  suspend) swaylock -f && systemctl suspend ;;
  logout) loginctl terminate-session "${XDG_SESSION_ID:-}" ;;
  reboot) systemctl reboot ;;
  shutdown) systemctl poweroff ;;
esac
