{ inputs, ... }:

{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      config,
      monitors,
      ...
    }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      home.packages = builtins.attrValues (import ./_scripts.nix pkgs);

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings = import ./_config.nix {
          inherit pkgs monitors;
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
