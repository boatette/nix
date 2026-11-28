{ config, lib, ... }:
{
  flake.lib.rebuild =
    let
      inherit (config.flake.constants) flakeDir repo;

      writeFlake = "(cd ${flakeDir} && nix run .#write-flake)";

      os = mode: "nh os ${mode} ${flakeDir}";

      owner = lib.head (lib.splitString "/" repo);

      # my own projects' working trees in ~/Projects, built without a lock update; new files need git add
      devOverrides = lib.concatStrings (
        lib.mapAttrsToList
          (
            name: input:
            " --override-input ${name} git+file://${dirOf flakeDir}/Projects/${lib.removePrefix "github:${owner}/" input.url}"
          )
          (
            lib.filterAttrs (
              _: input: lib.hasPrefix "github:${owner}/" (input.url or "")
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
        writeFlake
        ;

      dryBuild = "nixos-rebuild dry-build --flake ${flakeDir}";

      clean = "nh clean all ${cleanArgs}";

      upgrade = "${update} && ${os "switch"}";
    };
}
