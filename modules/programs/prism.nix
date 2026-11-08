{ inputs, ... }:
{
  flake.modules.homeManager.prism =
    { osConfig, pkgs, ... }:
    let
      # default bundles jdk8/17/21/25; 21 covers 1.20.5+, 25 covers 26.x
      prism = pkgs.prismlauncher.override {
        jdks = [
          pkgs.jdk25
          pkgs.jdk21
        ];
      };
    in
    {
      home.packages = [ (inputs.self.lib.nvidiaOffloadWrap pkgs osConfig prism "prismlauncher") ];
    };
}
