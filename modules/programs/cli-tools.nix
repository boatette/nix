{ inputs, ... }:
{
  flake-file.inputs = {
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rose-pine-eza = {
      url = "github:rose-pine/eza";
      flake = false;
    };
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
          opencode
        ])
        ++ [
          inputs.claude-code.packages.${system}.default
        ];

      xdg.configFile."eza/theme.yml".source = "${inputs.rose-pine-eza}/dist/rose-pine.yml";
    };
}
