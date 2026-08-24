{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.input = {
    keyboard = {
      layout = "us,us";
      variant = ",dvp";
      options = "caps:super,grp:win_space_toggle";
    };

    touchpad.natural_scroll = true;

    cursor = {
      theme = "capitaine-cursors";
      hide_when_typing = true;
      hide_timeout_ms = 5000;
    };
  };
}
