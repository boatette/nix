{ inputs, ... }:
{
  flake-file.inputs.umbriel = {
    url = "github:noctalia-dev/umbriel";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.umbriel =
    { config, ... }:
    {
      imports = [ inputs.umbriel.nixosModules.default ];

      programs.umbriel.enable = true;

      systemd.packages = [ config.programs.umbriel.package ];

      systemd.user.services.umbriel = {
        restartIfChanged = false;
        enableDefaultPath = false;
      };
    };

  flake.modules.homeManager.umbriel =
    { pkgs, ... }:
    {
      imports = [ inputs.umbriel.homeModules.default ];

      programs.umbriel.enable = true;

      home.packages = with pkgs; [
        wl-clipboard
        libnotify
      ];
    };

  perSystem =
    { system, ... }:
    {
      packages.umbriel = inputs.umbriel.packages.${system}.default;
    };
}
