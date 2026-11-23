{
  # qutebrowser's search engine, on localhost only
  flake.modules.nixos.aspire =
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

          ui = {
            # qutebrowser's tab titles otherwise all read "SearXNG"
            query_in_title = true;
            results_on_new_tab = true;
            hotkeys = "vim";
          };

          # the preferences page saves every value into a cookie that outranks these; locked ones ignore it
          preferences.lock = [
            "favicon_resolver"
            "query_in_title"
            "results_on_new_tab"
          ];

          plugins = {
            "searx.plugins.infinite_scroll.SXNGPlugin".active = true;
            "searx.plugins.oa_doi_rewrite.SXNGPlugin".active = true;
          };

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

      # it downloads the tracker url remover's rules once at start, which fails before dns is up
      systemd.services.searx = {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      };
    };
}
