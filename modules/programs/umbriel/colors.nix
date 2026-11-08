{
  flake.modules.homeManager.umbriel =
    { config, ... }:
    let
      inherit (config.constants) palette;

      c = name: "#${palette.${name}}";
      ca = name: alpha: "#${palette.${name}}${alpha}";
    in
    {
      programs.umbriel.settings = {
        colors = {
          background = c "overlay";
          text_primary = c "text";
          text_muted = c "subtle";
          accent_primary = c "rose";
          accent_secondary = c "foam";
          warning = c "pine";
          error = c "love";
          insert_hint = ca "pine" "80";
          backdrop = c "overlay";

          border = {
            focused = c "rose";
            unfocused = c "overlay";
            outer = c "base";
          };

          overview = {
            background_tint = ca "base" "88";
            badge = c "rose";
            workspace_background = c "base";
          };

          tab_bar = {
            background = c "overlay";
            text = c "subtle";
            active = c "rose";
            active_text = c "base";
            active_unfocused = c "overlay";
            active_unfocused_text = c "text";
            urgent = c "love";
            urgent_text = c "base";
          };

          title_bar = {
            background = c "overlay";
            background_unfocused = c "base";
            text = c "text";
            text_unfocused = c "subtle";
            close = c "love";
            close_glyph = c "base";
            close_glyph_hover = c "base";
            maximize = c "rose";
            maximize_glyph = c "base";
            maximize_glyph_hover = c "base";
            minimize = c "foam";
            minimize_glyph = c "base";
            minimize_glyph_hover = c "base";
          };
        };

        window_rule = [
          {
            match.is_scratchpad = true;
            border_color_focused = c "pine";
            # pine at 30% over base
            border_color_unfocused = "#203244";
          }
        ];
      };
    };
}
