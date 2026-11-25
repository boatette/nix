{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    let
      inherit (inputs.self.constants) locale locales timeZone;
    in
    {
      time = { inherit timeZone; };

      i18n = {
        defaultLocale = locale;
        supportedLocales = locales;
      };
    };
}
