{
  # the gx7160 calls itself a gx7100; its own ppd lets the queue install while it sleeps
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      services = {
        avahi = {
          enable = true;
          nssmdns4 = true;
        };

        printing = {
          enable = true;
          # turning avahi on also turns this on, and it creates a second queue
          browsed.enable = false;
          drivers = [
            (pkgs.runCommandLocal "canon-gx7160-ppd" { } ''
              install -Dm644 ${./printing/canon-gx7160.ppd} $out/share/cups/model/canon-gx7160.ppd
            '')
          ];
        };
      };

      # the queue address is resolved over mdns, which cups does not wait for
      systemd.services.cups = {
        wants = [ "avahi-daemon.service" ];
        after = [ "avahi-daemon.service" ];
      };

      hardware.printers = {
        ensureDefaultPrinter = "Canon-GX7160";
        ensurePrinters = [
          {
            name = "Canon-GX7160";
            description = "Canon MAXIFY GX7160";
            deviceUri = "dnssd://Canon%20GX7100%20series._ipp._tcp.local/";
            model = "canon-gx7160.ppd";
            ppdOptions.PageSize = "A4";
          }
        ];
      };
    };
}
