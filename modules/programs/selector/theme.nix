{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.theme.templates.user.selector = {
        input_path = ./selector.toml;
        output_path = "${config.xdg.configHome}/selector/noctalia.toml";
        post_hook = "systemctl --user try-restart selector.service";
      };
    };
}
