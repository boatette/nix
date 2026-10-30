{ inputs, ... }:
{
  flake-file.inputs.umbriel = {
    url = "github:noctalia-dev/umbriel";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.umbriel = {
    programs.umbriel.enable = true;

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "foot.desktop" ];
    };
  };

  flake.modules.homeManager.umbriel =
    { osConfig, pkgs, ... }:
    {
      imports = [ inputs.umbriel.homeModules.default ];

      programs.umbriel = {
        enable = true;
        # the umbriel the session runs, not the flake's newer one, so the config and `umbriel msg` match it
        package = osConfig.programs.umbriel.package;
      };

      home.packages = with pkgs; [
        wl-clipboard
        libnotify
        jq
      ];
    };
}
