{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.idle = {
    behavior_order = [
      "lock"
      "screen-off"
      "lock-and-suspend"
    ];

    behavior =
      let
        step = action: timeout: {
          inherit action timeout;
          enabled = true;
        };
      in
      {
        lock = step "lock" 600.0;
        screen-off = step "screen_off" 660.0;
        lock-and-suspend = step "lock_and_suspend" 900.0;
      };
  };
}
