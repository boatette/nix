{

  flake.modules.homeManager.zellij.programs.zellij = {
    enable = true;

    settings = {
      pane_frames = false;
      default_layout = "compact";
      show_release_notes = false;
      show_startup_tips = false;

      ui.pane_frames = {
        rounded_corners = true;
        hide_session_name = true;
      };

      copy_on_select = true;
      scroll_buffer_size = 50000;
      simplified_ui = true;

      theme = "noctalia";

      themes.terminal = {
        fg = 7;
        bg = 0;
        black = 0;
        red = 1;
        green = 2;
        yellow = 3;
        blue = 4;
        magenta = 5;
        cyan = 6;
        white = 7;
        orange = 3;
      };
    };
  };
}
