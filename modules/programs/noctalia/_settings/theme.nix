{
  homeDirectory,
  templates,
  ...
}:

{
  theme = {
    pure_black_dark = false;

    templates = {
      enable_builtin_templates = true;
      enable_community_templates = true;

      builtin_ids = [
        "btop"
        "foot"
        "ghostty"
        "gtk3"
        "gtk4"
        "kcolorscheme"
        "niri"
        "qt"
      ];
      community_ids = [
        "zen-browser"
        "discord"
        "lazygit"
        "papirus-icons"
        "prismlauncher"
        "steam"
        "yazi"
        "bat"
        "zellij"
      ];

      user = {
        konsole = {
          input_path = "${templates}/konsole/konsole.colorscheme";
          output_path = "${homeDirectory}/.local/share/konsole/Noctalia.colorscheme";
        };
        nvim = {
          input_path = "${templates}/nvim/nvim.lua";
          output_path = "${homeDirectory}/.config/nvim/noctalia.lua";
          post_hook = "pkill -SIGUSR1 nvim";
        };
        palette = {
          input_path = "${templates}/palette/palette.json";
          output_path = "${homeDirectory}/.cache/noctalia/palette.json";
        };
        selector = {
          input_path = "${templates}/selector/selector.toml";
          output_path = "${homeDirectory}/.config/selector/noctalia.toml";
          post_hook = "systemctl --user try-restart selector.service";
        };
        starship = {
          input_path = "${templates}/starship/starship.toml";
          output_path = "${homeDirectory}/.config/starship.toml";
        };
      };
    };
  };
}
