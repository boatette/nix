{
  flake.modules.nixos.greeter =
    { config, ... }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings.appearance.hide_logo = true;
        settings.keyboard = { inherit (config.services.xserver.xkb) layout; };
      };

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.noctalia.greeter.apply-appearance" &&
                subject.local && subject.active && subject.isInGroup("wheel")) {
                return polkit.Result.YES;
            }
        });
      '';
    };
}
