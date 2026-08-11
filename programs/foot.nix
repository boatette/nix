{
    flake.modules.homeManager.desktop =
        {
            config,
            ...
        }:
        {
            programs.foot = {
                enable = true;

                settings = {
                    main = {
                        include = "${config.xdg.configHome}/foot/themes/noctalia";

                        font = "JetBrainsMono Nerd Font:size=12";
                        pad = "14x14";
                    };

                    colors-dark = {
                        alpha = 0.8;
                        blur = "yes";
                    };
                };
            };
        };
}
