_:

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
      "boatette/auto-theme"
      "boatette/binary-clock"
    ];

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
        kind = "git";
        location = "git@github.com:boatette/noctalia-plugins.git";
        name = "Personal";
      }
    ];
  };

  plugin_settings = {
    "avivbintangaringga/nix-monitor" = {
      branch = "nixos-26.05";
      update_command = "nix flake update --flake ~/nix";
    };
    "boatette/auto-theme".default_dynamic_scheme = "vibrant";
    "noctalia/screen_recorder".copy_to_clipboard = true;
    "noctalia/wallhaven".download_dir = "~/Pictures/Wallpapers/Dynamic";
  };
}
