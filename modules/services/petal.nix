{ inputs, ... }:
let
  port = 8190;
in
{
  flake-file.inputs.petal = {
    url = "git+file:///home/boatette/Projects/petal";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # the phone app's server, over the tailnet only; it starts comfyui when asked and stops it when idle
  flake.modules.nixos.petal = {
    home-manager.sharedModules = [ inputs.self.modules.homeManager.petal ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];
  };

  flake.modules.homeManager.petal = {
    imports = [ inputs.petal.homeModules.default ];

    services.petal = {
      enable = true;

      settings = {
        listen = "[::]:${toString port}";
        comfy = "/mnt/storage/ai/comfy";
      };
    };
  };
}
