{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.animation = {
    enabled = true;
    duration_ms = 140;
    curve = "appleEase";

    beziers.appleEase = [
      0.25
      1.0
      0.5
      1.0
    ];

    springs.appleSpring = {
      damping = 0.9;
      stiffness = 420;
    };

    windows_in = {
      enabled = true;
      duration_ms = 140;
      curve = "appleEase";
      style = "popin";
      scale = 0.9;
    };

    windows_out = {
      enabled = true;
      duration_ms = 110;
      curve = "appleEase";
      style = "fade";
    };

    windows_move = {
      enabled = true;
      duration_ms = 170;
      curve = "appleSpring";
    };

    workspaces = {
      enabled = true;
      duration_ms = 190;
      curve = "appleSpring";
    };

    overview = {
      enabled = true;
      duration_ms = 190;
      curve = "appleEase";
    };

    scratchpad = {
      enabled = true;
      duration_ms = 170;
      curve = "appleSpring";
      dim = 0.3;
      blur = true;
      scale = 0.95;
      maximize = false;
      fullscreen = false;
    };

    border = {
      enabled = true;
      duration_ms = 100;
      curve = "linear";
    };

    dim_unfocused = {
      enabled = false;
      duration_ms = 140;
      curve = "appleEase";
      dim = 0.0;
    };

    layers = {
      enabled = true;
      duration_ms = 110;
      curve = "appleEase";
    };
  };
}
