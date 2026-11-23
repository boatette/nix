{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    let
      inherit (inputs.self.constants) locale;
    in
    {
      time.timeZone = inputs.self.constants.timeZone;

      i18n = {
        defaultLocale = locale;
        supportedLocales = [
          "${locale}/UTF-8"
          # bambu-studio has no en_AU translation, falls back to en_GB, and exits if that locale is missing
          "en_GB.UTF-8/UTF-8"
        ];
      };
    };
}
