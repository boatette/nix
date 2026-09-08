{ inputs, ... }:
{
  flake-file.inputs.yazi-plugins = {
    url = "github:yazi-rs/plugins";
    flake = false;
  };

  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    let
      plugin = name: "${inputs.yazi-plugins}/${name}.yazi";
    in
    {
      programs.yazi = {
        enable = true;

        extraPackages = with pkgs; [
          poppler-utils
          resvg
        ];

        plugins = {
          full-border = {
            package = plugin "full-border";
            setup = true;
          };
          git = {
            package = plugin "git";
            setup = true;
            settings.order = 1500;
          };

          chmod = plugin "chmod";
          jump-to-char = plugin "jump-to-char";
          mount = plugin "mount";
          smart-enter = plugin "smart-enter";
          smart-filter = plugin "smart-filter";
          smart-paste = plugin "smart-paste";
          toggle-pane = plugin "toggle-pane";
          vcs-files = plugin "vcs-files";
        };

        settings = {
          mgr.show_hidden = true;

          plugin.prepend_fetchers = [
            {
              url = "*";
              run = "git";
              group = "git";
            }
            {
              url = "*/";
              run = "git";
              group = "git";
            }
          ];
        };

        keymap.mgr.prepend_keymap = [
          {
            on = "l";
            run = "plugin smart-enter";
            desc = "Enter the child directory, or open the file";
          }
          {
            on = "p";
            run = "plugin smart-paste";
            desc = "Paste into the hovered directory, or the CWD";
          }
          {
            on = "f";
            run = "plugin jump-to-char";
            desc = "Jump to char";
          }
          {
            on = "F";
            run = "plugin smart-filter";
            desc = "Smart filter";
          }
          {
            on = "T";
            run = "plugin toggle-pane min-preview";
            desc = "Show or hide the preview pane";
          }
          {
            on = "M";
            run = "plugin mount";
            desc = "Mount manager";
          }
          {
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = [
              "g"
              "m"
            ];
            run = "plugin vcs-files";
            desc = "Show Git file changes";
          }
        ];

        theme = {
          flavor = {
            dark = "noctalia";
            light = "noctalia";
          };

          status = {
            sep_left = {
              open = "";
              close = "";
            };
            sep_right = {
              open = "";
              close = "";
            };
          };

          tabs.sep_inner = {
            open = "";
            close = "";
          };

          indicator.padding = {
            open = "█";
            close = "█";
          };
        };
      };
    };
}
