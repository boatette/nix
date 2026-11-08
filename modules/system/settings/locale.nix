{
  flake.modules.nixos.locale =
    { config, ... }:
    let
      inherit (config.constants) locale;
    in
    {
      time.timeZone = config.constants.timeZone;

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
