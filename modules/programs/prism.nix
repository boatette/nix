{ inputs, ... }:
{
  flake.modules.homeManager.prism =
    {
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      offload = osConfig.hardware.nvidia.prime.offload.enable or false;

      prismlauncher =
        if offload then
          pkgs.symlinkJoin {
            inherit (pkgs.prismlauncher)
              name
              pname
              version
              meta
              ;
            paths = [ pkgs.prismlauncher ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/prismlauncher ${
                lib.concatStringsSep " " (
                  lib.mapAttrsToList (name: value: "--set ${name} ${value}") inputs.self.lib.nvidiaOffloadEnv
                )
              }
            '';
          }
        else
          pkgs.prismlauncher;
    in
    {
      home.packages = [ prismlauncher ];
    };
}
