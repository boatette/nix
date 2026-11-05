{ inputs, ... }:
{
  flake-file.inputs.umbriel = {
    url = "github:noctalia-dev/umbriel/cachix";
  };

  flake.modules.nixos.umbriel.programs.umbriel.enable = true;

  flake.modules.homeManager.umbriel =
    { pkgs, ... }:
    {
      imports = [ inputs.umbriel.homeModules.default ];

      programs.umbriel = {
        enable = true;
      };

      home.packages = with pkgs; [
        wl-clipboard
        libnotify
        jq
      ];
    };
}
