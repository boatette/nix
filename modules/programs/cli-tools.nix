{ inputs, ... }:
{
  flake-file.inputs = {
    rose-pine-eza = {
      url = "github:rose-pine/eza";
      flake = false;
    };
  };

  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
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
      ];

      xdg.configFile."eza/theme.yml".source = "${inputs.rose-pine-eza}/dist/rose-pine.yml";
    };
}
