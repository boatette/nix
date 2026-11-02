{
  # niri's default animations, 20% faster: durations ×0.8, and spring stiffness ×1/0.8², as a
  # spring's settle time scales with 1/√stiffness. umbriel's springs are niri's (damping ratio,
  # unit mass, settled within 1e-4), and easeoutexpo/easeoutquad are the same functions
  flake.modules.homeManager.umbriel.programs.umbriel.settings.animation = {
    enabled = true;

    springs = {
      # window-movement, window-resize, horizontal-view-movement and overview-open-close: 1.0, 800
      movement = {
        damping = 1.0;
        stiffness = 1250.0;
      };
      # workspace-switch: 1.0, 1000
      workspace = {
        damping = 1.0;
        stiffness = 1562.5;
      };
    };

    # window-open: 150ms ease-out-expo, growing from half size as it fades in
    windows_in = {
      duration_ms = 120;
      curve = "easeoutexpo";
      style = "popin";
      scale = 0.5;
    };

    # window-close: 150ms ease-out-quad, shrinking to 0.8 as it fades out
    windows_out = {
      duration_ms = 120;
      curve = "easeoutquad";
      style = "popin";
      scale = 0.8;
    };

    # nixpkgs' umbriel resizes under windows_move too; newer ones split out windows_resize
    windows_move.curve = "movement";

    workspaces = {
      style = "slide";
      curve = "workspace";
    };

    overview = {
      curve = "movement";
      workspace_curve = "workspace";
    };

    # niri has no scratchpad; it moves like a window
    scratchpad = {
      curve = "movement";
      dim = 0.42;
    };

    # niri changes the focus ring's color at once and doesn't animate layer-shell surfaces
    border.enabled = false;
    layers.enabled = false;
  };
}
