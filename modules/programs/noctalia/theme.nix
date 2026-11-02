{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.theme = {
    source = "builtin";
    builtin = "Rosé Pine";
    mode = "dark";

    templates = {
      community_ids = [
        "discord"
        "libreoffice"
        "prismlauncher"
        "steam"
      ];
    };
  };
}
