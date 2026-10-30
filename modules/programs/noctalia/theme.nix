{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.theme = {
    source = "builtin";
    builtin = "Rosé Pine";
    mode = "dark";

    templates = {
      # umbriel is themed by the user template in umbriel/template.nix
      builtin_ids = [ ];

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
