{
  # qutebrowser's search engine, on localhost only
  flake.modules.nixos.searxng =
    { lib, ... }:
    {
      services.searx = {
        enable = true;

        settings.server = {
          bind_address = "127.0.0.1";
          port = 8192;
          secret_key = "$SEARX_SECRET_KEY";
        };
      };

      # the key only signs image proxy urls, so a fresh one each start saves persisting a secret
      systemd.services.searx-init.script = lib.mkBefore ''
        SEARX_SECRET_KEY=$(head -c 32 /dev/urandom | base64)
        export SEARX_SECRET_KEY
      '';
    };
}
