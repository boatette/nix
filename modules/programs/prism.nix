{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    let
      # default bundles jdk8/17/21/25; 25 runs 1.20.5 and later
      prism = pkgs.prismlauncher.override { jdks = [ pkgs.jdk25 ]; };
    in
    {
      home.packages = [ (inputs.self.lib.nvidiaOffloadWrap pkgs prism "prismlauncher") ];
    };
}
