{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    { config, pkgs, ... }:
    let
      alpha = inputs.self.lib.colours.alphaHex inputs.self.constants.glass.opacity;

      base = "{{ colors.surface_container_low.default.hex }}";
    in
    {
      # luciole has no rosé pine port, so noctalia renders its builtin scheme through its own luciole template
      programs.noctalia.settings.theme.templates.user.luciole = {
        # only the window base is glass, as surface also fills dialogs and tooltips with no blur behind them
        input_path = pkgs.substitute {
          src = "${config.programs.noctalia.package}/share/noctalia/assets/templates/luciole/colors.toml";
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
