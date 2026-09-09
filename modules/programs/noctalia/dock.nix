{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.dock = {
    enabled = true;

    reserve_space = false;
    smart_auto_hide = true;

    background_opacity = 0.8;

    icon_size = 40;

    radius = 0;

    show_dots = true;
    show_instance_count = false;

    pinned = [
      "com.mitchellh.ghostty"
      "org.qutebrowser.qutebrowser"
      "vesktop"
      "steam"
      "org.prismlauncher.PrismLauncher"
      "com.stremio.Stremio"
      "org.kde.dolphin"
    ];
  };
}
