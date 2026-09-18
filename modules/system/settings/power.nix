{
  flake.modules.nixos.power =
    { lib, pkgs, ... }:
    let
      lowBattery = 25;

      switch = pkgs.writeShellApplication {
        name = "power-profile-switch";
        meta.description = "match the power profile to the charge state";

        runtimeInputs = [ pkgs.power-profiles-daemon ];

        text = ''
          supplies=/sys/class/power_supply
          state=/run/power-profile-switch/last

          mains=no
          plugged=no
          capacity=100

          for supply in "$supplies"/*; do
            if [ "$(cat "$supply/type" 2>/dev/null || true)" = Mains ]; then
              mains=yes

              if [ "$(cat "$supply/online" 2>/dev/null || true)" = 1 ]; then
                plugged=yes
              fi
            fi
          done

          for supply in "$supplies"/*; do
            if [ "$(cat "$supply/type" 2>/dev/null || true)" != Battery ]; then
              continue
            fi

            capacity=$(cat "$supply/capacity" 2>/dev/null || echo 100)

            if [ "$mains" = no ] &&
              [ "$(cat "$supply/status" 2>/dev/null || true)" != Discharging ]; then
              plugged=yes
            fi

            break
          done

          if [ "$plugged" = no ] && [ "$capacity" -lt ${toString lowBattery} ]; then
            want=power-saver
          else
            want=balanced
          fi

          if [ "$want" = "$(cat "$state" 2>/dev/null || true)" ]; then
            exit 0
          fi

          powerprofilesctl set "$want"
          printf '%s\n' "$want" >"$state"
        '';
      };
    in
    {
      services.power-profiles-daemon.enable = true;

      systemd = {
        services.power-profile-switch = {
          description = "Match the power profile to the charge state";

          wantedBy = [ "multi-user.target" ];
          wants = [ "power-profiles-daemon.service" ];
          after = [ "power-profiles-daemon.service" ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe switch;

            RuntimeDirectory = "power-profile-switch";
            RuntimeDirectoryPreserve = true;
          };
        };

        timers.power-profile-switch = {
          description = "Re-check the charge state for the power profile";
          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnBootSec = "1min";
            OnUnitActiveSec = "1min";
            AccuracySec = "20s";
          };
        };
      };

      services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-profile-switch.service"
      '';
    };
}
