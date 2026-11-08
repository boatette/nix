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
        supportedLocales = [ "${locale}/UTF-8" ];
      };
    };
}
