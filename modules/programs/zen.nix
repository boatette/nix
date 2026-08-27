{ inputs, ... }:
{
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.zen =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      home.packages = [ inputs.zen-browser.packages.${system}.beta ];
    };
}
