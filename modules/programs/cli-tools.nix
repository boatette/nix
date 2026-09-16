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
          cachix
          dust
          eza
          fd
          gh
          jq
          lm_sensors
          nix-tree
          ripgrep
          microfetch
          tldr
        ])
        ++ [
          inputs.claude-code.packages.${system}.default
        ];
    };
}
