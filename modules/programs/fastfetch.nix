{
  flake.modules.homeManager.fastfetch.programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "builtin";
        source = "none";
      };

      display.separator = " ›  ";

      modules = [
        "break"
        {
          type = "title";
          format = "{user-name}@{host-name}";
        }
        "break"
        {
          type = "os";
          key = "OS  ";
          keyColor = "31";
        }
        {
          type = "kernel";
          key = "KER ";
          keyColor = "32";
        }
        {
          type = "disk";
          key = "AGE ";
          keyColor = "33";
          folders = "/";
          format = "{create-time:10} ({days} days)";
        }
        {
          type = "shell";
          key = "SH  ";
          keyColor = "34";
        }
        {
          type = "terminal";
          key = "TER ";
          keyColor = "35";
        }
        {
          type = "wm";
          key = "WM  ";
          keyColor = "36";
        }
        "break"
      ];
    };
  };
}
