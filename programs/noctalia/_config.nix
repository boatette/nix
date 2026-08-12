{
  homeDirectory,
  templates,
  footLiveTheme,
  primaryMonitor,
}:

{
  audio.enable_sounds = true;

  backdrop.enabled = true;

  bar.default = {
    background_opacity = 0.8;
    border_width = 1.0;
    capsule = false;
    capsule_radius = 0.0;
    center = [
      "clock"
      "bar"
    ];
    end = [
      "tray"
      "network"
      "bluetooth"
      "volume"
      "notifications"
      "battery"
      "cat"
    ];
    font_family = "JetBrainsMono NF";
    margin_edge = 8;
    margin_ends = 8;
    padding = 8;
    radius = 0;
    start = [
      "workspaces"
      "nix-monitor"
      "media"
      "audio_visualizer"
    ];
    widget_spacing = 12;
  };

  brightness.sync_all_monitors = true;

  calendar = {
    enabled = true;
    account.personal_google = {
      name = "Personal Calendar";
      type = "google";
    };
  };

  config = { };

  control_center = {
    width = 800;
    calendar.show_week_numbers = true;
  };

  desktop_widgets = {
    schema_version = 2;
    widget_order = [ "desktop-widget-0000000000000001" ];
    grid = {
      cell_size = 16;
      major_interval = 4;
      visible = true;
    };
    widget = {
      desktop-widget-0000000000000001 = {
        box_height = 240.0;
        box_width = 432.0;
        cx = 280.0;
        cy = 932.0;
        output = "eDP-1";
        rotation = 0.0;
        type = "boatette/binary-clock:desktop";

        settings = {
          show_digits = false;
          show_headers = false;
          show_labels = false;
          show_separators = false;
        };
      };
    };
  };

  dock = {
    border_width = 1.0;
    concave_edge_corners = false;
    icon_size = 40;
    enabled = true;
    margin_edge = 8;
    pinned = [
      "foot"
      "zen-beta"
      "vesktop"
      "steam"
      "org.prismlauncher.PrismLauncher"
      "com.stremio.Stremio"
      "nemo"
    ];
    radius = 0;
    reserve_space = false;
    show_dots = true;
    show_instance_count = false;
    smart_auto_hide = true;
  };

  hooks = {
    colors_changed = [
      "noctalia msg plugin boatette/auto-theme:auto-theme all colors-changed"
      "${footLiveTheme}/bin/foot-live-theme"
    ];
    theme_mode_changed = [
      "noctalia msg plugin boatette/auto-theme:auto-theme all theme-mode-changed"
    ];
    wallpaper_changed = [
      ''noctalia msg plugin boatette/auto-theme:auto-theme all wallpaper-changed "$NOCTALIA_WALLPAPER_PATH"''
    ];
  };

  hot_corners = {
    enabled = true;
    top_right.action = "control_center";
  };

  keybinds = {
    down = [
      "Down"
      "Ctrl+j"
    ];
    left = [
      "Left"
      "Ctrl+h"
    ];
    right = [
      "Right"
      "Ctrl+l"
    ];
    tab_next = [
      "Tab"
      "Ctrl+n"
    ];
    tab_previous = [
      "Shift+ISO_Left_Tab"
      "Ctrl+p"
    ];
    up = [
      "Up"
      "Ctrl+k"
    ];
  };

  location.auto_locate = true;

  lockscreen.monitors = [ primaryMonitor ];

  lockscreen_widgets = {
    enabled = true;
    schema_version = 2;
    widget_order = [ "lockscreen-login-box@${primaryMonitor}" ];

    grid = {
      cell_size = 16;
      major_interval = 4;
      visible = true;
    };

    widget."lockscreen-login-box@${primaryMonitor}" = {
      box_height = 70.0;
      box_width = 400.0;
      cx = 960.0;
      cy = 898.0;
      output = primaryMonitor;
      rotation = 0.0;
      type = "login_box";

      settings = {
        background_color = "surface_variant";
        background_opacity = 0.0;
        background_radius = 0.0;
        center_password_text = true;
        input_opacity = 1.0;
        input_radius = 0.0;
        layout = "compact";
        show_caps_lock = true;
        show_keyboard_layout = false;
        show_login_button = false;
        show_media = true;
        show_session_buttons = true;
        show_unlock_hint = false;
        show_weather = true;
      };
    };
  };

  osd = {
    position = "bottom_center";
    position_vertical = "center_left";
  };

  plugin_settings = {
    "avivbintangaringga/nix-monitor" = {
      branch = "nixos-26.05";
      update_command = "nix flake update --flake ~/nix";
    };
    "noctalia/screen_recorder".copy_to_clipboard = true;
    "noctalia/wallhaven".download_dir = "~/Pictures/Wallpapers/Dynamic";
    "boatette/auto-theme".default_dynamic_scheme = "wallust";
  };

  plugins = {
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
        kind = "git";
        location = "https://github.com/noctalia-dev/official-plugins";
        name = "official";
      }
      {
        kind = "git";
        location = "https://github.com/noctalia-dev/community-plugins";
        name = "community";
      }
      {
        kind = "git";
        location = "git@github.com:boatette/noctalia-plugins.git";
        name = "Personal";
      }
    ];
  };

  shell = {
    corner_radius_scale = 0.0;
    niri_overview_type_to_launch_enabled = true;
    polkit_agent = true;
    popup_shadows = false;
    screen_time_enabled = true;
    settings_window_translucent = true;

    greeter_sync = {
      auto_sync = true;
      privilege_command = "pkexec";
    };

    launcher = {
      app_grid = true;
      providers = {
        calculator.prefix = "=";
        emoji.prefix = ":";
        wallpaper.prefix = "";
        windows.prefix = "@";
      };
    };

    panel = {
      launcher_placement = "attached";
      list_item_background = true;
      transparency_mode = "glass";
      open_near_click_control_center = true;
    };

    session.actions = [
      {
        action = "lock";
        shortcut = "l";
        variant = "default";
      }
      {
        action = "logout";
        shortcut = "e";
        variant = "default";
      }
      {
        action = "lock_and_suspend";
        shortcut = "u";
        variant = "default";
      }
      {
        action = "reboot";
        shortcut = "r";
        variant = "default";
      }
      {
        action = "shutdown";
        shortcut = "s";
        variant = "destructive";
      }
    ];

    screen_corners = {
      enabled = false;
      size = 36;
    };
  };

  theme.templates = {
    builtin_ids = [
      "btop"
      "foot"
      "gtk3"
      "gtk4"
      "qt"
    ];
    community_ids = [
      "zen-browser"
      "discord"
      "lazygit"
      "papirus-icons"
      "prismlauncher"
      "steam"
      "yazi"
      "bat"
      "zellij"
    ];

    user = {
      starship = {
        input_path = "${templates}/starship/starship.toml";
        output_path = "${homeDirectory}/.config/starship.toml";
      };
      nvim = {
        input_path = "${templates}/nvim/nvim.lua";
        output_path = "${homeDirectory}/.config/nvim/noctalia.lua";
        post_hook = "pkill -SIGUSR1 nvim";
      };
      wayland-select = {
        input_path = "${templates}/wayland-select/wayland-select.toml";
        output_path = "${homeDirectory}/.config/wayland-select/colors.toml";
      };
      niri = {
        input_path = "${templates}/niri/niri.kdl";
        output_path = "${homeDirectory}/.config/niri/noctalia.kdl";
        post_hook = "bash ${templates}/niri/apply.sh";
      };
    };
  };

  wallpaper.transition_on_startup = true;

  widget = {
    bar = {
      enabled = false;
      type = "boatette/binary-clock:bar";
    };
    battery = {
      hide_when_full = true;
      hide_when_plugged = true;
    };
    bluetooth.hide_when_no_connected_device = true;
    cat.type = "dotnetrob/cat:cat";
    launcher.custom_image_colorize = true;
    media = {
      hide_when_no_media = true;
      title_scroll = "always";
    };
    network.show_label = false;
    nix-monitor = {
      show_text = false;
      type = "avivbintangaringga/nix-monitor:nix-monitor";
    };
    tray.drawer = true;
    volume.show_label = false;
    workspaces = {
      labels_only_when_occupied = true;
      # style = "minimal";
    };
  };
}
