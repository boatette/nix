{ inputs, ... }:
{
  # unofficial launcher: runs the Android build of Bedrock, so it needs a Google
  # account that owns Minecraft on the Play Store to download the game
  flake.modules.homeManager.bedrock =
    { osConfig, pkgs, ... }:
    {
      # the ui spawns mcpelauncher-client, which inherits the offload env
      home.packages = [
        (inputs.self.lib.nvidiaOffloadWrap pkgs osConfig pkgs.mcpelauncher-ui-qt "mcpelauncher-ui-qt")
      ];
    };
}
