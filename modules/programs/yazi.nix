{ inputs, ... }:
{
  flake-file.inputs.rose-pine-yazi = {
    url = "github:rose-pine/yazi";
    flake = false;
  };

  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;

        flavors.rose-pine = "${inputs.rose-pine-yazi}/flavors/rose-pine.yazi";

        extraPackages = with pkgs; [
          poppler-utils
          resvg
        ];

        plugins = {
          git = {
            package = pkgs.yaziPlugins.git;
            setup = true;
            settings.order = 1500;
          };

          chmod = pkgs.yaziPlugins.chmod;
          jump-to-char = pkgs.yaziPlugins.jump-to-char;
          mount = pkgs.yaziPlugins.mount;
          smart-enter = pkgs.yaziPlugins.smart-enter;
          smart-filter = pkgs.yaziPlugins.smart-filter;
          smart-paste = pkgs.yaziPlugins.smart-paste;
          toggle-pane = pkgs.yaziPlugins.toggle-pane;
          vcs-files = pkgs.yaziPlugins.vcs-files;
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
            dark = "rose-pine";
            light = "rose-pine";
          };

          app.overall = { };

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
