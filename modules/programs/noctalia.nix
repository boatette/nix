{ inputs, ... }:
{
  flake-file.inputs.noctalia.url = "github:noctalia-dev/noctalia/cachix";

  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      home.packages = with pkgs; [
        imagemagick
        glib
      ];
    };
}
