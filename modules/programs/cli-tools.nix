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
          btop
          dust
          eza
          fd
          gh
          jq
          lm_sensors
          nix-tree
          ripgrep
        ])
        ++ [
          inputs.claude-code.packages.${system}.default
        ];

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
}
