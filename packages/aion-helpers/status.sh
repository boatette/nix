# feeds the aion bar one line at a time, using only builtins in the loop apart from sleep
battery() {
  local bat=/sys/class/power_supply/BAT1 capacity status sign=""
  battery_text=""
  [[ -r $bat/capacity ]] || return 0

  read -r capacity <"$bat/capacity"
  read -r status <"$bat/status"
  # aspire has no ac device, so battery status is the only plugged-in signal
  [[ $status == Charging || $status == Full ]] && sign="+"

  battery_text="$sign$capacity%  "
}

# aion-updates creates this file while nixos-unstable is ahead of the running system
update() {
  update_text=""
  if [[ -e ${XDG_RUNTIME_DIR:-/run/user/$UID}/aion-update ]]; then
    update_text="!  "
  fi
}

while :; do
  battery
  update
  printf '%s%s%(%a %d %b  %H:%M)T\n' "$update_text" "$battery_text" -1 || exit 0
  # wake on :00 and :30, so the clock changes on the minute
  sleep $((30 - EPOCHSECONDS % 30))
done
