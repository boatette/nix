{ inputs, ... }:

{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      config,
      osConfig,
      ...
    }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings = import ./_config.nix {
          inherit pkgs;
          inherit (osConfig.preferences) monitors;
          inherit (config.home) homeDirectory;
        };
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.noctalia = import ./_package.nix { inherit inputs pkgs; };
    };
}
