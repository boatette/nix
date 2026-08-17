{
  homeDirectory,
  templates,
  ...
}:

{
  theme = {
    builtin = "Noctalia";
    community_palette = "Oxocarbon";
    custom_palette = "";
    mode = "dark";
    pure_black_dark = false;
    source = "builtin";
    wallpaper_scheme = "m3-content";

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
        nvim = {
          input_path = "${templates}/nvim/nvim.lua";
          output_path = "${homeDirectory}/.config/nvim/noctalia.lua";
          post_hook = "pkill -SIGUSR1 nvim";
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
