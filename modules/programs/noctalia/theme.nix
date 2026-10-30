{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.theme = {
    source = "builtin";
    builtin = "Rosé Pine";
    mode = "dark";

    templates = {
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
