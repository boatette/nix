{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.theme.templates.user.nvim = {
        input_path = ./noctalia.lua;
        output_path = "${config.home.homeDirectory}/.config/nvim/noctalia.lua";
        post_hook = "pkill -SIGUSR1 nvim";
      };
    };
}
