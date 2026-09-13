{
  flake.modules.homeManager.noctalia =
    { lib, pkgs, ... }:
    let
      reload = pkgs.writeShellApplication {
        name = "foot-apply-colours";

        runtimeInputs = with pkgs; [
          gawk
          procps
        ];

        text = ''
          theme="''${XDG_CONFIG_HOME:-$HOME/.config}/foot/themes/noctalia"
          [ -r "$theme" ] || exit 0

          payload=$(awk -F= '
            $1 ~ /^regular[0-7]$/ { idx = substr($1, 8);     palette = palette ";" idx ";#" $2 }
            $1 ~ /^bright[0-7]$/  { idx = substr($1, 7) + 8; palette = palette ";" idx ";#" $2 }

            $1 == "foreground"           { fg = $2 }
            $1 == "background"           { bg = $2 }
            $1 == "cursor"               { split($2, pair, " "); cursor = pair[2] }
            $1 == "selection-foreground" { selection_fg = $2 }
            $1 == "selection-background" { selection_bg = $2 }

            END {
              esc = sprintf("%c", 27)
              st = esc "\\"

              if (palette != "")      printf "%s]4%s%s",     esc, palette, st
              if (fg != "")           printf "%s]10;#%s%s",  esc, fg, st
              if (bg != "")           printf "%s]11;#%s%s",  esc, bg, st
              if (cursor != "")       printf "%s]12;#%s%s",  esc, cursor, st
              if (selection_bg != "") printf "%s]17;#%s%s",  esc, selection_bg, st
              if (selection_fg != "") printf "%s]19;#%s%s",  esc, selection_fg, st
            }
          ' "$theme")

          [ -n "$payload" ] || exit 0

          while read -r foot_pid; do
            while read -r child_pid; do
              pty=$(readlink "/proc/$child_pid/fd/0" 2>/dev/null) || continue
              case "$pty" in
                /dev/pts/*) printf '%s' "$payload" >"$pty" || true ;;
              esac
            done < <(pgrep -P "$foot_pid" || true)
          done < <(pgrep -x foot || true)
        '';
      };
    in
    {
      programs.noctalia.settings.hooks.colors_changed = [ (lib.getExe reload) ];
    };
}
