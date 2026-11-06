{ inputs, ... }:
{
  flake-file.inputs.selector = {
    url = "git+file:///home/boatette/Projects/selector";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.selector = {
    imports = [ inputs.selector.homeModules.selector ];

    programs.selector = {
      enable = true;
      systemd.enable = true;

      settings = {
        blur = true;
        corner_radius = inputs.self.constants.glass.radius;

        fade_out = 100;
      };
    };
  };
}
