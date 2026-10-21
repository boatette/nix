{ inputs, ... }:
{
  flake-file.inputs.rose-pine-tm-theme = {
    url = "github:rose-pine/tm-theme";
    flake = false;
  };

  flake.modules.homeManager.bat = {
    programs.bat = {
      enable = true;

      config.theme = "rose-pine";

      themes.rose-pine = {
        src = inputs.rose-pine-tm-theme;
        file = "dist/rose-pine.tmTheme";
      };
    };

    home.sessionVariables = {
      MANROFFOPT = "-c";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
  };
}
