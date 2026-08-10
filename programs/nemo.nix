{
    flake.homeModules.desktop =
        { pkgs, ... }:
        {
            home.packages = [ pkgs.nemo-with-extensions ];

            dconf.settings = {
                "org/cinnamon/desktop/applications/terminal" = {
                    exec = "foot";
                    exec-arg = "--";
                };

                "org/nemo/preferences" = {
                    show-hidden-files = true;
                    disable-menu-warning = true;
                };

                "org/nemo/icon-view".captions = [
                    "none"
                    "none"
                    "none"
                ];

                "org/nemo/list-view".enable-folder-expansion = true;

                "org/nemo/window-state" = {
                    start-with-menu-bar = false;
                    side-pane-view = "places";
                };
            };
        };
}
