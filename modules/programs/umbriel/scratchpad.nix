{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.scratchpad = [
    { name = "main"; }
    {
      name = "rmpc";
      spawn_when_empty = "foot --app-id=rmpc rmpc";
    }
  ];
}
