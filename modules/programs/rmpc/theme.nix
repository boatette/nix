{ inputs, ... }:
{
  flake-file.inputs.rose-pine-rmpc = {
    url = "github:rose-pine/rmpc";
    flake = false;
  };

  flake.modules.homeManager.rmpc =
    { pkgs, ... }:
    let
      port = "${inputs.rose-pine-rmpc}/rosepine-main/rmpc_default_no_border/themes/rosepine-main.ron";

      # the port fills every cell with base, which the terminal's alpha doesn't apply to
      theme = pkgs.runCommandLocal "rosepine-main.ron" { } ''
        sed 's/^    background_color: .*/    background_color: None,/' ${port} > $out
        grep -q '^    background_color: None,$' $out
      '';
    in
    {
      xdg.configFile."rmpc/themes/rosepine-main.ron".source = theme;
    };
}
