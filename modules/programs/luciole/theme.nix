{
  flake.modules.homeManager.luciole =
    { osConfig, ... }:
    {
      # no rosé pine port exists; luciole takes noctalia's palette, so noctalia renders its builtin scheme into it
      programs.noctalia.settings.theme.templates.user.luciole = {
        input_path = "${osConfig.programs.luciole.package}/share/luciole/templates/colors.toml";
        output_path = "$XDG_CONFIG_HOME/luciole/colors.toml";
      };
    };
}
