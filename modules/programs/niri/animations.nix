{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings.animations =
    let
      spring = damping-ratio: stiffness: epsilon: {
        spring._props = { inherit damping-ratio stiffness epsilon; };
      };
      easing = duration-ms: curve: { inherit duration-ms curve; };
    in
    {
      workspace-switch = spring 1.0 1000 0.0001;
      window-open = easing 200 "ease-out-quad";
      window-close = easing 200 "ease-out-cubic";
      horizontal-view-movement = spring 1.0 900 0.0001;
      window-movement = spring 1.0 800 0.0001;
      window-resize = spring 1.0 1000 0.0001;
      config-notification-open-close = spring 0.6 1200 0.001;
      screenshot-ui-open = easing 300 "ease-out-quad";
      overview-open-close = spring 1.0 900 0.0001;
    };
}
