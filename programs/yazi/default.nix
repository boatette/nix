{
    flake.modules.homeManager.dev = {
        programs.yazi = {
            enable = true;

            settings.mgr.show_hidden = true;

            theme = {
                flavor = {
                    dark = "noctalia";
                    light = "noctalia";
                };

                status = {
                    sep_left = {
                        open = "";
                        close = "";
                    };
                    sep_right = {
                        open = "";
                        close = "";
                    };
                };

                tabs.sep_inner = {
                    open = "";
                    close = "";
                };

                indicator.padding = {
                    open = "█";
                    close = "█";
                };
            };
        };
    };
}
