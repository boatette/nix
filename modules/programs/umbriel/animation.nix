{
  flake.modules.homeManager.umbrielprograms.umbriel.settings = {
    animation = {
      enabled = true;
      duration_ms = 250;
      curve = "easeout";

      # Window opening
      windows_in = {
        enabled = true;
        effect = "";
        style = "popin";
        scale = 0.93;
        curve = "spring:0.92,900";
        duration_ms = 190;
      };

      # Window closing
      windows_out = {
        enabled = true;
        effect = "";
        style = "popin";
        scale = 0.96;
        duration_ms = 150;
        curve = "spring:1,1200";
      };

      # Window movement and resizing
      windows_move = {
        enabled = true;
        effect = "";
        curve = "spring:0.85,1000";
      };

      # Workspace switching
      workspaces = {
        enabled = true;
        style = "slide";
        curve = "spring:0.92,900";
      };

      # Overview animation
      overview = {
        enabled = true;
        curve = "spring:0.95,850";
        workspace_curve = "spring:0.95,1000";
      };

      # Focus border animation
      border = {
        enabled = true;
        curve = "spring:1,900";
      };
    };
  };
}
