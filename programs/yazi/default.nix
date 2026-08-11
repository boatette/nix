{
    flake.homeModules.dev = {
        programs.yazi = {
            enable = true;

            settings.mgr.show_hidden = true;

            theme.flavor = {
                dark = "noctalia";
                light = "noctalia";
            };

            plugins.no-status = {
                package = ./no-status.yazi;
                setup = true;
            };
        };
    };
}
