{ inputs, ... }:

let
  mkNiri =
    {
      pkgs,
      monitors ? { },
    }:
    let
      inherit (pkgs) lib;

      primary = lib.findFirst (name: monitors.${name}.primary) null (lib.attrNames monitors);
    in
    inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;

      settings = {
        input = import ./_input.nix;
        outputs = import ./_outputs.nix { inherit lib monitors; };
        layout = import ./_layout.nix;
        binds = import ./_binds.nix { inherit pkgs; };
        window-rules = import ./_window-rules.nix;
        layer-rules = import ./_layer-rules.nix;
        switch-events = import ./_switch-events.nix;

        extraConfig = ''
          ${import ./_workspaces.nix { inherit lib primary; }}

          include optional=true "~/.config/niri/noctalia.kdl"
        '';
      }
      // import ./_misc.nix;
    };
in
{
  flake.modules.nixos.desktop =
    { config, pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = mkNiri {
          inherit pkgs;
          inherit (config.preferences) monitors;
        };

        useNautilus = false;
      };
    };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      xdg.configFile."niri/.keep".text = "";

      home.packages = with pkgs; [
        xwayland-satellite
        wl-clipboard
        libnotify
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.niri = mkNiri { inherit pkgs; };
    };
}
