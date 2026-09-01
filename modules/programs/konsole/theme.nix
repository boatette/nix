{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.theme.templates.user.konsole = {
        input_path = ./konsole.colorscheme;
        output_path = "${config.xdg.dataHome}/konsole/Noctalia.colorscheme";
      };
    };
}
