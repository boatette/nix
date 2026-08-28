{
  flake.modules.homeManager.umbriel.programs.umbriel.settings = {
    include.files = [ "noctalia.toml" ];

    # TODO: add switch-events

    general = {
      focus_on_activate = true;
      show_cheatsheet = false;
    };
  };
}
