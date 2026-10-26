{ inputs, ... }:
{
  flake.modules.homeManager.prism =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      offload = osConfig.hardware.nvidia.prime.offload.enable or false;

      # default bundles jdk8/17/21/25; 21 covers 1.20.5+, 25 covers 26.x
      prism = pkgs.prismlauncher.override {
        jdks = [
          pkgs.jdk25
          pkgs.jdk21
        ];
      };

      prismlauncher =
        if offload then
          pkgs.symlinkJoin {
            inherit (prism)
              name
              pname
              version
              meta
              ;
            paths = [ prism ];
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
          prism;
    in
    {
      home.packages = [ prismlauncher ];
    };
}
