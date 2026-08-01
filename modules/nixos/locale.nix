{ lib, ... }:

let
    locale = "en_AU.UTF-8";
in

{
    time.timeZone = "Australia/Hobart";

    i18n = {
        defaultLocale = locale;

        extraLocaleSettings = lib.genAttrs [
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

    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };
}
