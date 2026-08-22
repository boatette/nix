{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.theme = {
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
        "qt"
        "umbriel"
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
    };
  };
}
