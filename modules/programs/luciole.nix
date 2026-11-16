{ inputs, ... }:
{
  flake-file.inputs.luciole = {
    url = "github:noctalia-dev/luciole";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.luciole = {
    imports = [ inputs.luciole.nixosModules.default ];

    programs.luciole.enable = true;
  };
}
