{ inputs, ... }:
{
  # runs the android build, so it needs a google account that owns minecraft
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      # the ui spawns mcpelauncher-client, which inherits the offload env
      home.packages = [
        (inputs.self.lib.nvidiaOffloadWrap pkgs pkgs.mcpelauncher-ui-qt "mcpelauncher-ui-qt")
      ];
    };
}
