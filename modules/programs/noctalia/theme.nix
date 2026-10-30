{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.theme = {
    source = "builtin";
    builtin = "Rosé Pine";
    mode = "dark";

    templates = {
      builtin_ids = [ "umbriel" ];

      community_ids = [
        "claude-code"
        "discord"
        "libreoffice"
        "prismlauncher"
        "steam"
      ];
    };
  };
}
