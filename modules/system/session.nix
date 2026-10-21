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

          GDK_BACKEND = "wayland,x11";
          GSK_RENDERER = "ngl";
        };
      };

      services = {
        gnome.gnome-keyring.enable = true;
        # home-manager's ssh-agent is the one SSH_AUTH_SOCK points at
        gnome.gcr-ssh-agent.enable = false;

        gvfs.enable = true;
        upower.enable = true;

        speechd.enable = false;

        xserver.xkb = {
          inherit (config.constants.keyboard) layout options;
        };
      };
    };
}
