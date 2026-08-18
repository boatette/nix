{ lib, monitors }:

let
  mkOutput =
    m:
    {
      inherit (m) scale transform;
      position = _: {
        props = { inherit (m.position) x y; };
      };
    }
    // lib.optionalAttrs (m.mode != null) { inherit (m) mode; };
in
lib.mapAttrs (_: mkOutput) monitors
