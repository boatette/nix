{
  # qutebrowser's search engine, on localhost only
  flake.modules.nixos.searxng =
    { config, lib, ... }:
    {
      services.searx = {
        enable = true;

        settings = {
          server = {
            bind_address = "127.0.0.1";
            port = 8192;
            secret_key = "$SEARX_SECRET_KEY";
          };

          search = {
            default_lang = lib.replaceStrings [ "_" ] [ "-" ] (
              lib.head (lib.splitString "." config.constants.locale)
            );
            favicon_resolver = "duckduckgo";
          };

          # qutebrowser's tab titles otherwise all read "SearXNG"
          ui.query_in_title = true;

          # off upstream, and most of what gets searched here
          engines = [
            {
              name = "nixos wiki";
              disabled = false;
            }
          ];
        };

        # the defaults, but searxng logs an error on every start unless the file exists
        faviconsSettings.favicons.cfg_schema = 1;
      };

      # the key only signs proxied favicon and image urls, so a fresh one each start saves persisting a secret
      systemd.services.searx-init.script = lib.mkBefore ''
        SEARX_SECRET_KEY=$(head -c 32 /dev/urandom | base64)
        export SEARX_SECRET_KEY
      '';
    };
}
