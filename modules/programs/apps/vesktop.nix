{
  flake.modules.homeManager.apps =
    { lib, pkgs, ... }:
    let
      enableTransparency = pkgs.writeShellApplication {
        name = "vesktop-enable-transparency";
        runtimeInputs = with pkgs; [
          coreutils
          jq
          procps
        ];
        text = ''
          settings="''${XDG_CONFIG_HOME:-$HOME/.config}/vesktop/settings/settings.json"

          mkdir -p "$(dirname "$settings")"
          [ -f "$settings" ] || printf '{}\n' > "$settings"

          if [ "$(jq -r '.transparent' "$settings" 2>/dev/null)" = "true" ]; then
            exit 0
          fi

          tmp="$(mktemp "$settings.XXXXXX")"
          if jq '.transparent = true' "$settings" > "$tmp" 2>/dev/null; then
            mv "$tmp" "$settings"
            echo "vesktop: enabled window transparency"
          else
            rm -f "$tmp"
            echo "vesktop: settings.json is not valid JSON, left untouched" >&2
            exit 0
          fi

          if pgrep -f 'Vesktop/resources/app.asar' > /dev/null; then
            echo "vesktop: currently running - fully quit it (tray -> Quit) and relaunch" >&2
          fi
        '';
      };
    in
    {
      home.activation.vesktopTransparency = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe enableTransparency}
      '';

      xdg.configFile."vesktop/settings/quickCss.css".text = ''
        :root {
          --bg-src-1: var(--bg-1);
          --bg-src-2: var(--bg-2);
          --bg-src-3: var(--bg-3);
          --bg-src-4: var(--bg-4);
          --hover-src: var(--hover);
          --active-src: var(--active);
          --message-hover-src: var(--message-hover);
        }

        body {
          --alpha: 50%;

          --bg-1: color-mix(in srgb, var(--bg-src-1) var(--alpha), transparent) !important;
          --bg-2: color-mix(in srgb, var(--bg-src-2) var(--alpha), transparent) !important;
          --bg-3: color-mix(in srgb, var(--bg-src-3) var(--alpha), transparent) !important;
          --bg-4: color-mix(in srgb, var(--bg-src-4) var(--alpha), transparent) !important;

          --hover: color-mix(in srgb, var(--hover-src) 40%, transparent) !important;
          --active: color-mix(in srgb, var(--active-src) 55%, transparent) !important;
          --message-hover: color-mix(in srgb, var(--message-hover-src) 40%, transparent) !important;

          --remove-bg-layer: on !important;
          --transparency-tweaks: on !important;
        }

        html,
        body,
        #app-mount {
          background: transparent !important;
        }
      '';
    };
}
