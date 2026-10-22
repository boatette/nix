{ inputs, ... }:
{
  flake-file.inputs.system24 = {
    url = "github:refact0r/system24";
    flake = false;
  };

  flake.modules.homeManager.vesktop = {
    programs.vesktop = {
      enable = true;

      vencord = {
        themes.system24-rose-pine = builtins.readFile "${inputs.system24}/theme/flavors/system24-rose-pine.theme.css";

        # keep plugin settings changed in the app, only the theme is declared
        mutableSettings = true;
        settings.enabledThemes = [ "system24-rose-pine.css" ];
      };
    };
  };
}
