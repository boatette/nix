{ config, lib, ... }:
{
  flake.lib.rebuild =
    flakeDir:
    let
      writeFlake = "(cd ${flakeDir} && nix run .#write-flake)";

      os = mode: "nh os ${mode} ${flakeDir}";

      # builds the uncommitted changes of every git+file input without a lock update; new files need git add
      devOverrides = lib.concatStrings (
        lib.mapAttrsToList (name: input: " --override-input ${name} ${input.url}") (
          lib.filterAttrs (
            _: input: lib.hasPrefix "git+file://" (toString (input.url or ""))
          ) config.flake-file.inputs
        )
      );

      osDev = mode: "${os mode}${devOverrides}";

      cleanArgs = "--keep 5 --keep-since 7d";

      update = "${writeFlake} && nix flake update --flake ${flakeDir} --commit-lock-file";
    in
    {
      inherit
        os
        osDev
        cleanArgs
        update
        ;

      dryBuild = "nixos-rebuild dry-build --flake ${flakeDir}";

      clean = "nh clean all ${cleanArgs}";

      upgrade = "${update} && ${os "switch"}";
    };
}
