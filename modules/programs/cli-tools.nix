{ inputs, ... }:
{
  flake-file.inputs = {
    rose-pine-eza = {
      url = "github:rose-pine/eza";
      flake = false;
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grok-build-nix = {
      url = "github:AodhanHayter/grok-build-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
        ])
        ++ [
          inputs.claude-code.packages.${system}.default
          inputs.grok-build-nix.packages.${system}.default
        ];

      xdg.configFile."eza/theme.yml".source = "${inputs.rose-pine-eza}/dist/rose-pine.yml";
    };
}
