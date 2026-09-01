{
  flake.modules.nixos.session =
    { config, ... }:
    {
      environment = {
        profileRelativeSessionVariables = {
          QT_PLUGIN_PATH = [ "/lib/qt-6/plugins" ];
          QML2_IMPORT_PATH = [ "/lib/qt-6/qml" ];
        };

        sessionVariables = {
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
      };

      services = {
        gvfs.enable = true;
        tumbler.enable = true;
        upower.enable = true;

        xserver.xkb = {
          inherit (config.constants.keyboard) layout variant options;
        };
      };
    };
}
