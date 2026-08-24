{
  flake.modules.homeManager.noctalia.programs.noctalia.settings = {
    control_center = {
      width = 800;
      sidebar = "full";
      sidebar_section = "none";
      show_shortcut_labels = false;

      calendar.show_week_numbers = true;
    };

    notification.border = false;

    osd = {
      border = false;
      position = "bottom_center";
      position_vertical = "center_left";
    };
  };
}
