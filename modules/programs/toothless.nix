{ inputs, ... }:
{
  flake-file.inputs.toothless = {
    url = "git+file:///home/boatette/Projects/toothless";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # a Night Fury in a corner of the desktop that wakes up and gets excited as the cpu gets busy
  flake.modules.homeManager.toothless = {
    imports = [ inputs.toothless.homeModules.default ];

    programs.toothless.enable = true;
  };
}
