{
  flake.lib.rebuild =
    flakeDir:
    let
      writeFlake = "nix run ${flakeDir}#write-flake";

      os = mode: "nh os ${mode} ${flakeDir}";
    in
    {
      inherit writeFlake os;

      dryBuild = "nixos-rebuild dry-build --flake ${flakeDir}";

      update = "${writeFlake} && nix flake update --flake ${flakeDir} --commit-lock-file";

      upgrade = "${writeFlake} && nix flake update --flake ${flakeDir} --commit-lock-file && ${os "switch"}";
    };
}
