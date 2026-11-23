{ config, lib, ... }:
{
  flake.lib.rebuild =
    let
      inherit (config.flake.constants) flakeDir repo;

      writeFlake = "(cd ${flakeDir} && nix run .#write-flake)";

      os = mode: "nh os ${mode} ${flakeDir}";

      owner = lib.head (lib.splitString "/" repo);

      # my own projects' working trees in ~/Projects, built without a lock update; new files need git add
      workingTree =
        url:
        if lib.hasPrefix "git+file://" url then
          url
        else if lib.hasPrefix "github:${owner}/" url then
          "git+file://${dirOf flakeDir}/Projects/${lib.removePrefix "github:${owner}/" url}"
        else
          null;

      devOverrides = lib.concatStrings (
        lib.mapAttrsToList (name: input: " --override-input ${name} ${workingTree input.url}") (
          lib.filterAttrs (_: input: workingTree (input.url or "") != null) config.flake-file.inputs
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
