{ inputs, ... }:
{
  # unofficial launcher: runs the Android build of Bedrock, so it needs a Google
  # account that owns Minecraft on the Play Store to download the game
  flake.modules.homeManager.bedrock =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      offload = osConfig.hardware.nvidia.prime.offload.enable or false;

      launcher = pkgs.mcpelauncher-ui-qt;

      # the ui spawns mcpelauncher-client, which inherits the offload env
      mcpelauncher =
        if offload then
          pkgs.symlinkJoin {
            inherit (launcher)
              name
              pname
              version
              meta
              ;
            paths = [ launcher ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/mcpelauncher-ui-qt ${
                lib.concatStringsSep " " (
                  lib.mapAttrsToList (name: value: "--set ${name} ${value}") inputs.self.lib.nvidiaOffloadEnv
                )
              }
            '';
          }
        else
          launcher;
    in
    {
      home.packages = [ mcpelauncher ];
    };
}
