{
  # noctalia's umbriel template themes the rest; the main config is applied after its include
  flake.modules.homeManager.umbriel =
    { config, ... }:
    let
      inherit (config.constants) palette;
    in
    {
      programs.umbriel.settings.colors = {
        border = {
          focused = "#${palette.rose}";
          unfocused = "#${palette.muted}";
        };

        # umbriel has no urgent border, only an urgent tab
        tab_bar.urgent = "#${palette.love}";
      };
    };
}
