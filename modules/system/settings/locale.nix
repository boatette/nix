{
  flake.modules.nixos.locale =
    { config, lib, ... }:
    let
      inherit (config.constants) locale;
    in
    {
      time.timeZone = config.constants.timeZone;

      i18n.defaultLocale = locale;
      i18n.extraLocaleSettings = lib.genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (_: locale);
    };
}
