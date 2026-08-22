{
  flake.modules.homeManager.umbriel.programs.umbriel.settings = {
    include.files = [ "noctalia.toml" ];

    general = {
      autostart = [ ];
      mod_key = "Super";
      xwayland = true;
      show_cheatsheet = false;
      focus_on_activate = false;
    };

    environment = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Umbriel";
    };

    workspaces.back_and_forth = false;
  };
}
