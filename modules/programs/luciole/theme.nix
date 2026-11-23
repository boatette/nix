{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    { osConfig, pkgs, ... }:
    let
      alpha = inputs.self.lib.colours.alphaHex inputs.self.constants.glass.opacity;

      base = "{{ colors.surface_container_low.default.hex }}";
    in
    {
      # luciole has no rosé pine port, so noctalia renders its builtin scheme into luciole's template
      programs.noctalia.settings.theme.templates.user.luciole = {
        # only the window base is glass, as surface also fills dialogs and tooltips with no blur behind them
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
