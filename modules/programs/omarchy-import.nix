{ inputs, ... }:
{
  flake-file.inputs.omarchy-import = {
    url = "path:/home/boatette/Projects/omarchy-import";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.scripts =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.omarchy-import.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
