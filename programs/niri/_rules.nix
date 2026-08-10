[
    {
        geometry-corner-radius = 0;
        clip-to-geometry = true;
        draw-border-with-background = false;
        background-effect = {
            blur = true;
            xray = true;
        };
        popups.background-effect = {
            blur = true;
            xray = false;
        };
    }

    {
        matches = [ { app-id = ''^dev\.noctalia\.Noctalia$''; } ];
        open-floating = true;
        default-column-width.fixed = 1080;
        default-window-height.fixed = 920;
    }

    {
        matches = [
            { app-id = "zen"; }
            { app-id = "vesktop"; }
            { app-id = "steam"; }
            { app-id = "gimp"; }
            { app-id = "libreoffice"; }
        ];
        open-maximized = true;
    }

    {
        matches = [
            { app-id = "^xdg-desktop-portal-gtk$"; }
            { app-id = ''^org\.gtk\.FileChooserDialog$''; }
            { title = ''^(Open|Save|Select|Import|Export)\b''; }
        ];
        excludes = [
            { app-id = "^zen"; }
            { app-id = "^vesktop$"; }
            { app-id = "^steam$"; }
        ];
        open-floating = true;
        default-column-width.proportion = 0.0;
        max-width = 800;
        max-height = 1000;
    }

    {
        matches = [
            { title = "^Picture-in-Picture$"; }
            { title = "Sign in - Google Accounts"; }
            {
                app-id = "^steam$";
                title = ".*Friends.*";
            }
        ];
        open-floating = true;
    }

    {
        matches = [ { title = ''\b(Dialog|Properties|Preferences|Settings|Rename|Authentication)$''; } ];
        excludes = [
            { app-id = "^zen"; }
            { app-id = "^vesktop$"; }
        ];
        open-floating = true;
    }

    {
        matches = [
            {
                app-id = "steam";
                title = ''^notificationtoasts_\d+_desktop$'';
            }
        ];
        default-floating-position = _: {
            props = {
                x = 10;
                y = 10;
                relative-to = "bottom-right";
            };
        };
        geometry-corner-radius = 0;
        border.off = _: { };
    }

    {
        matches = [
            { app-id = ''^org\.gnome\.Nautilus$''; }
            { app-id = "^thunar"; }
            { app-id = "^nemo"; }
        ];
        opacity = 0.8;
    }
]
