{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.theme.templates.user.konsole = {
        input_path = ./konsole.colorscheme;
        output_path = "${config.home.homeDirectory}/.local/share/konsole/Noctalia.colorscheme";
      };
    };
}
