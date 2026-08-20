{
  self,
  config,
  lib,
  ...
}:

{
  flake.nixosConfigurations = config.flake.lib.mkNixos "x86_64-linux" "aspire";

  flake.modules.nixos.aspire =
    { config, ... }:
    let
      inherit (config.preferences) monitors;

      primary = lib.findFirst (name: monitors.${name}.primary) null (lib.attrNames monitors);
    in
    {
      imports = with self.modules.nixos; [
        base
        desktop

        backup
        gaming
        libvirt
      ];

      networking.hostName = "aspire";

      system.stateVersion = "26.05";

      preferences.monitors = {
        "eDP-1" = {
          mode = "1920x1080@144";
          primary = true;
        };

        "HDMI-A-1" = {
          mode = "1920x1080@75.000";
          position.x = -1920;
        };
      };

      programs.noctalia-greeter.settings.output = lib.mkIf (primary != null) {
        name = primary;
        scale = monitors.${primary}.scale;
      };
    };
}
