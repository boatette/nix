{ inputs, self, ... }:

{
  flake.modules.nixos.desktop =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
        self.modules.nixos.monitors
      ];

      home-manager = {
        extraSpecialArgs = { inherit (config.preferences) monitors; };

        users.${config.preferences.user.name}.imports = [
          self.modules.homeManager.desktop
        ];
      };

      programs = {
        appimage = {
          enable = true;
          binfmt = true;
          package = pkgs.appimage-run.override {
            extraPkgs = pkgs: [
              pkgs.webkitgtk_4_1
              pkgs.gtk3
              pkgs.glib
            ];
          };
        };

        localsend.enable = true;

        noctalia-greeter = {
          enable = true;

          settings = {
            appearance.hide_logo = true;

            keyboard = { inherit (config.services.xserver.xkb) layout; };
          };
        };
      };

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.noctalia.greeter.apply-appearance" &&
                subject.local && subject.active && subject.isInGroup("wheel")) {
                return polkit.Result.YES;
            }
        });
      '';

      services = {
        gvfs.enable = true;
        tumbler.enable = true;
        upower.enable = true;

        xserver.xkb = {
          layout = "us";
          variant = "";
        };
      };
    };
}
