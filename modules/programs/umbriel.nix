{
  flake.modules.nixos.aspire.programs.umbriel.enable = true;

  flake.modules.homeManager.boatette =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      toml = pkgs.formats.toml { };
    in
    {
      options.programs.umbriel.settings = lib.mkOption {
        inherit (toml) type;
        default = { };
        description = "umbriel's config.toml";
      };

      config = {
        xdg.configFile."umbriel/config.toml".source =
          toml.generate "umbriel-config.toml" config.programs.umbriel.settings;

        home.packages = with pkgs; [
          libnotify
          wl-clipboard
        ];
      };
    };
}
