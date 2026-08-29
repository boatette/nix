{
  flake.modules.homeManager =
    let
      colorsFile = config: "${config.xdg.cacheHome}/noctalia/papirus-colors";
      iconDir = config: "${config.xdg.dataHome}/icons";

      mkRecolor =
        pkgs: config:
        pkgs.writeShellApplication {
          name = "noctalia-papirus-folders";

          runtimeInputs = with pkgs; [
            gawk
            papirus-folders
          ];

          text = ''
            [ -f ${colorsFile config} ] || exit 0

            mapfile -t lines < ${colorsFile config}
            [ "''${#lines[@]}" -ge 2 ] || exit 0

            target=''${lines[0]//[^0-9a-fA-F]/}
            [ "''${#target}" -ge 6 ] || exit 0

            closest=$(awk -v t="''${target:0:6}" -v m="''${lines[-1]}" '
              function rgb2hsv(r, g, b,   mx, mn, d, h, s, v, x) {
                r /= 255; g /= 255; b /= 255
                mx = (r > g) ? (r > b ? r : b) : (g > b ? g : b)
                mn = (r < g) ? (r < b ? r : b) : (g < b ? g : b)
                v = mx
                d = mx - mn
                if (d == 0) { h = 0; s = 0 }
                else {
                  s = d / mx
                  if (mx == r) { x = (g - b) / d; if (x < 0) x += 6; h = 60 * x }
                  else if (mx == g) { h = 60 * (((b - r) / d) + 2) }
                  else { h = 60 * (((r - g) / d) + 4) }
                }
                return h SUBSEP s SUBSEP v
              }

              function hsv(hex) {
                return rgb2hsv(strtonum("0x" substr(hex, 1, 2)),
                               strtonum("0x" substr(hex, 3, 2)),
                               strtonum("0x" substr(hex, 5, 2)))
              }

              BEGIN {
                split(hsv(t), want, SUBSEP)

                n = split(m, entries)
                for (i = 1; i <= n; i++) {
                  split(entries[i], pair, ":")
                  split(hsv(pair[2]), have, SUBSEP)

                  dh = want[1] - have[1]
                  if (dh < 0) dh = -dh
                  if (dh > 180) dh = 360 - dh
                  dh /= 180
                  ds = want[2] - have[2]
                  dv = want[3] - have[3]

                  d = 10 * (want[2] * have[2]) * dh * dh + ds * ds + 0.3 * dv * dv

                  if (best == "" || d < best) { best = d; name = pair[1] }
                }

                print name
              }
            ')

            [ -n "$closest" ] || exit 0

            for variant in Papirus Papirus-Dark Papirus-Light; do
                [ -d "${iconDir config}/$variant" ] || continue
                papirus-folders -t "$variant" -C "$closest" >/dev/null
            done
          '';
        };
    in
    {
      appearance =
        {
          pkgs,
          lib,
          config,
          ...
        }:
        let
          papirus = pkgs.papirus-icon-theme;

          papirusThemes = [
            "Papirus"
            "Papirus-Light"
            "Papirus-Dark"
          ];

          icons = iconDir config;
        in
        {
          kde.settings.kdeglobals.Icons.Theme = "Papirus";

          gtk.iconTheme = {
            name = "Papirus";
            package = papirus;
          };

          home.activation.papirusIcons = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            stamp="${icons}/.papirus-source"

            if [ "$(cat "$stamp" 2>/dev/null)" != "${papirus}" ]; then
                run mkdir -p ${icons}
                for theme in ${lib.escapeShellArgs papirusThemes}; do
                    run rm -rf "${icons}/$theme"
                    run cp -a --reflink=auto --no-preserve=mode \
                        "${papirus}/share/icons/$theme" "${icons}/$theme"
                done
                run echo "${papirus}" > "$stamp"

                run ${lib.getExe (mkRecolor pkgs config)}
            fi
          '';
        };

      noctalia =
        {
          pkgs,
          lib,
          config,
          ...
        }:
        {
          programs.noctalia.settings.theme.templates.user.papirus-icons = {
            input_path = ./papirus-icons.colors;
            output_path = colorsFile config;
            post_hook = lib.getExe (mkRecolor pkgs config);
          };
        };
    };
}
