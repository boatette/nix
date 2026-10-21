{
  flake.lib.rebuild =
    flakeDir:
    let
      writeFlake = "(cd ${flakeDir} && nix run .#write-flake)";

      os = mode: "nh os ${mode} ${flakeDir}";

      # builds aion's uncommitted changes without a lock update; new files need git add
      osDev = mode: "${os mode} --override-input aion git+file://${dirOf flakeDir}/Projects/aion";

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
