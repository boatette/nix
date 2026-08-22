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

            if [ ! -e "$target" ] || [ -L "$target" ]; then
                run rm -f $VERBOSE_ARG "$target"
                run install -m 644 $VERBOSE_ARG "$palette" "$target"
            fi
        done
      '';
    };
}
