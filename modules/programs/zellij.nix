{ inputs, ... }:
{
  flake-file.inputs.rose-pine-zellij = {
    url = "github:rose-pine/zellij";
    flake = false;
  };

  flake.modules.homeManager.zellij =
    { pkgs, ... }:
    {
      xdg.configFile."zellij/themes/rose-pine.kdl".source =
        "${inputs.rose-pine-zellij}/dist/rose-pine.kdl";

      programs.zellij = {
        enable = true;

        plugins = [ pkgs.zellijPlugins.autolock ];

        settings = {
          pane_frames = false;
          default_layout = "compact";
          show_release_notes = false;
          show_startup_tips = false;

          ui.pane_frames = {
            rounded_corners = true;
            hide_session_name = true;
          };

          copy_on_select = true;
          scroll_buffer_size = 50000;
          simplified_ui = true;

          serialize_pane_viewport = true;

          plugins.autolock = {
            is_enabled = true;
            triggers = "nvim|vim|fzf|yazi|lazygit|git|less|bat|claude";
            reaction_seconds = "0.3";
            print_to_log = false;
          };

          keybinds = {
            locked._children = [
              {
                bind = {
                  _args = [ "Alt z" ];
                  _children = [
                    {
                      MessagePlugin = {
                        _args = [ "autolock" ];
                        _children = [ { payload = "disable"; } ];
                      };
                    }
                    { SwitchToMode._args = [ "Normal" ]; }
                  ];
                };
              }
            ];
            shared._children = [
              {
                bind = {
                  _args = [ "Alt Shift z" ];
                  _children = [
                    {
                      MessagePlugin = {
                        _args = [ "autolock" ];
                        _children = [ { payload = "enable"; } ];
                      };
                    }
                  ];
                };
              }
            ];
          };

          theme = "rose-pine";
        };

        layouts.dev = ''
          layout {
              default_tab_template {
                  children
                  pane size=1 borderless=true {
                      plugin location="compact-bar"
                  }
              }

              tab name="code" focus=true
              tab name="claude" {
                  pane command="claude"
              }
              tab name="git" {
                  pane command="lazygit"
              }
              tab name="files" {
                  pane command="yazi"
              }
          }
        '';
      };
    };
}
