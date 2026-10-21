{
  flake.lib.rebuild =
    flakeDir:
    let
      writeFlake = "(cd ${flakeDir} && nix run .#write-flake)";

      os = mode: "nh os ${mode} ${flakeDir}";

      cleanArgs = "--keep 5 --keep-since 7d";

      update = "${writeFlake} && nix flake update --flake ${flakeDir} --commit-lock-file";
    in
    {
      inherit
        os
        cleanArgs
        update
        ;

      dryBuild = "nixos-rebuild dry-build --flake ${flakeDir}";

      clean = "nh clean all ${cleanArgs}";

      upgrade = "${update} && ${os "switch"}";
    };
}
