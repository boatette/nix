{
  flake.modules.homeManager.noctalia =
    { lib, config, ... }:
    lib.mkIf (builtins.pathExists ./palettes) {
      home.activation.noctaliaPalettes = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        palettes="${config.xdg.configHome}/noctalia/palettes"
        run mkdir -p "$palettes"

        for palette in ${./palettes}/*.json; do
            [ -e "$palette" ] || continue
            target="$palettes/$(basename "$palette")"

            # Only ever restore what is missing. A palette edited in place, by hand or through
            # the settings GUI, is not something a rebuild should quietly overwrite.
            if [ ! -e "$target" ] || [ -L "$target" ]; then
                run rm -f $VERBOSE_ARG "$target"
                run install -m 644 $VERBOSE_ARG "$palette" "$target"
            fi
        done
      '';
    };
}
