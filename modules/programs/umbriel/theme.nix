# NOTE: remove once noctalia updates
{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.theme.templates.user.umbriel = {
        input_path = ./umbriel.toml;
        output_path = "${config.xdg.configHome}/umbriel/noctalia.toml";
      };
    };
}
