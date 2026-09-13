{ inputs, ... }:
{
  flake-file.inputs.claude-code = {
    url = "github:sadjow/claude-code-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      home.packages =
        (with pkgs; [
          dust
          eza
          fd
          gh
          jq
          lm_sensors
          nix-tree
          ripgrep
          microfetch
        ])
        ++ [
          inputs.claude-code.packages.${system}.default
        ];
    };
}
