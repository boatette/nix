{
  flake.modules.homeManager.boatette =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      alpha = lib.toLower (
        lib.fixedWidthString 2 "0" (
          lib.toHexString (builtins.floor (config.constants.glass.opacity * 255 + 0.5))
        )
      );

      base = "{{ colors.surface_container_low.default.hex }}";
    in
    {
      # no rosé pine port exists; luciole takes noctalia's palette, so noctalia renders its builtin scheme into it
      programs.noctalia.settings.theme.templates.user.luciole = {
        # only the window base is glass: surface also fills luciole's own dialogs and tooltips, which have nothing blurred behind them
        input_path = pkgs.substitute {
          src = "${osConfig.programs.luciole.package}/share/luciole/templates/colors.toml";
          substitutions = [
            "--replace-fail"
            "${base}\""
            "${base}${alpha}\""
          ];
        };
        output_path = "$XDG_CONFIG_HOME/luciole/colors.toml";
      };
    };
}
