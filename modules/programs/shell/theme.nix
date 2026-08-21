{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.theme.templates.user.starship = {
        input_path = ./starship.toml;
        output_path = "${config.home.homeDirectory}/.config/starship.toml";
      };
    };
}
