{ inputs, ... }:
{
  flake.modules.nixos.aspire = {
    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      GDK_BACKEND = "wayland,x11";
      GSK_RENDERER = "ngl";
    };

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "foot.desktop" ];
    };

    services = {
      gnome.gnome-keyring.enable = true;
      # home-manager's ssh-agent is the one SSH_AUTH_SOCK points at
      gnome.gcr-ssh-agent.enable = false;

      gvfs.enable = true;
      upower.enable = true;

      speechd.enable = false;

      xserver.xkb = {
        inherit (inputs.self.constants.keyboard) layout options;
      };
    };
  };
}
