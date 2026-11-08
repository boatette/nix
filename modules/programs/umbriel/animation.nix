{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.animation = {
    windows_in = {
      scale = 0.93;
      curve = "spring:0.92,900";
    };

    windows_out = {
      scale = 0.96;
      curve = "spring:1,1200";
    };

    windows_move.curve = "spring:0.85,1000";
    windows_resize.curve = "spring:0.85,1000";

    workspaces.curve = "spring:0.92,900";

    overview = {
      curve = "spring:0.95,850";
      workspace_curve = "spring:0.95,1000";
    };
  };
}
