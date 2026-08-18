{
  flakeDir,
  pkgs,
  ...
}:

{
  plugins = {
    auto_update = true;

    enabled = [
      "noctalia/wallhaven"
      "h465855hgg/lyrics"
      "avivbintangaringga/nix-monitor"
      "dotnetrob/cat"
      "radimous/prismlauncher-instances"
      "yocraft/web-launcher"
      "nightwatch75/file-search"
    ]
    ++ pkgs.noctalia-plugins.pluginIds;

    source = [
      {
        enabled = true;
        kind = "git";
        location = "https://github.com/noctalia-dev/official-plugins";
        name = "official";
      }
      {
        enabled = true;
        kind = "git";
        location = "https://github.com/noctalia-dev/community-plugins";
        name = "community";
      }
      {
        enabled = true;
        kind = "path";
        location = "${pkgs.noctalia-plugins}";
        name = "Personal";
      }
    ];
  };

  plugin_settings = {
    "avivbintangaringga/nix-monitor" = {
      branch = "nixos-unstable";
      update_command = ''nix flake update --flake ${flakeDir} && { git -C ${flakeDir} commit -m "chore: update flake lock" flake.lock || true; } && sudo nixos-rebuild switch --flake ${flakeDir}'';
    };
    "boatette/auto-theme".default_dynamic_scheme = "vibrant";
    "noctalia/screen_recorder".copy_to_clipboard = true;
    "noctalia/wallhaven".download_dir = "~/Pictures/Wallpapers/Dynamic";
  };
}
