{

  flake-file.inputs.millennium = {
    url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
