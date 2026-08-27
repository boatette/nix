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
          fzf
          gh
          jq
          lm_sensors
          ripgrep
        ])
        ++ [
          inputs.claude-code.packages.${system}.default
        ];
    };

  flake.modules.homeManager.mime =
    { lib, ... }:
    let
      associations = lib.genAttrs [ "x-scheme-handler/claude-cli" ] (
        _: "claude-code-url-handler.desktop"
      );
    in
    {
      xdg.mimeApps.defaultApplications = associations;
      xdg.mimeApps.associations.added = associations;
    };
}
