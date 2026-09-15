{
  flake.modules.nixos.vm =
    { config, ... }:
    {
      home-manager.users.${config.constants.username}.programs.umbriel.settings.input.cursor.hardware_cursor =
        false;
    };
}
