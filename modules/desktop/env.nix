{
  flake.modules.nixos.desktop.environment.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";

    GDK_BACKEND = "wayland,x11";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DBUS_REMOTE = "1";

    GSK_RENDERER = "ngl";
  };
}
