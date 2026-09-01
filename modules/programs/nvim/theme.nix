{
  flake.modules.homeManager = {
    noctalia =
      { config, ... }:
      {
        programs.noctalia.settings.theme.templates.user.nvim = {
          input_path = ./noctalia.lua;
          output_path = "${config.xdg.configHome}/nvim/noctalia.lua";
          post_hook = "pkill -SIGUSR1 nvim";
        };
      };

    nvim.xdg.configFile."nvim/.keep".text = "";
  };
}
