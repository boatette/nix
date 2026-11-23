{ inputs, ... }:
{
  flake.modules.homeManager.boatette.programs.umbriel.settings =
    let
      inherit (inputs.self.lib.colours)
        alpha
        hex
        mix
        ;
    in
    {
      colors = {
        background = hex "overlay";
        backdrop = hex "overlay";
        text_primary = hex "text";
        text_muted = hex "subtle";

        accent_primary = hex "primary";
        accent_secondary = hex "secondary";
        warning = hex "warning";
        error = hex "error";
        insert_hint = alpha "tertiary" 0.5;

        border = {
          focused = hex "primary";
          unfocused = hex "overlay";
          outer = hex "base";
        };

        overview = {
          background_tint = alpha "base" 0.55;
          badge = hex "primary";
          workspace_background = hex "base";
        };

        tab_bar = {
          background = hex "overlay";
          text = hex "subtle";
          active = hex "primary";
          active_text = hex "base";
          active_unfocused = hex "overlay";
          active_unfocused_text = hex "text";
          urgent = hex "error";
          urgent_text = hex "base";
        };

        title_bar = {
          background = hex "overlay";
          background_unfocused = hex "base";
          text = hex "text";
          text_unfocused = hex "subtle";
          close = hex "error";
          close_glyph = hex "base";
          close_glyph_hover = hex "base";
          maximize = hex "primary";
          maximize_glyph = hex "base";
          maximize_glyph_hover = hex "base";
          minimize = hex "secondary";
          minimize_glyph = hex "base";
          minimize_glyph_hover = hex "base";
        };
      };

      window_rule = [
        {
          match.is_scratchpad = true;
          border_color_focused = hex "tertiary";
          border_color_unfocused = mix "tertiary" "base" 0.3;
        }
      ];
    };
}
