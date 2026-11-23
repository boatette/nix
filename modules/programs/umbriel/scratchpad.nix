{
  flake.modules.homeManager.boatette.programs.umbriel.settings.scratchpad = [
    { name = "main"; }
    {
      name = "rmpc";
      spawn_when_empty = "foot --app-id=rmpc rmpc";
    }
  ];
}
