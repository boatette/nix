{ inputs, ... }:
{
  flake-file.inputs.monitor-autorotate = {
    url = "git+file:///home/boatette/Projects/monitor-autorotate";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # turns the monitors between the profiles in flake.monitors as the Pico on the arm reports
  flake.modules.nixos.monitor-autorotate = {
    imports = [ inputs.monitor-autorotate.nixosModules.default ];

    services.monitor-autorotate.enable = true;
  };
}
